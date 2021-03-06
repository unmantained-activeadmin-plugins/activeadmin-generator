require 's3'
require 'aws-sdk'
require 'heroku-api'

module ::Bricks
  class Heroku < Base

    attr_reader :access_key, :access_secret, :bucket_name

    def apply?
      yes? "Will you be deploying to Heroku+S3?"
    end

    def before_bundle
      @heroku_username = ENV['HEROKU_USERNAME'] || ask("Heroku username:")
      @heroku_password = ENV['HEROKU_PASSWORD'] || ask("Heroku password:")
      @heroku_region = ENV['HEROKU_REGION'] || ask("Heroku region (eu or us):")
      @heroku_collaborators = ( ENV['HEROKU_COLLABORATORS'] || ask("Specify collaborators' emails:") ).split(/\s*,\s*/).map(&:strip)

      heroku = ::Heroku::API.new(username: @heroku_username, password: @heroku_password)

      begin
        begin
          @heroku_appname = ask("Please specify Heroku app name:")
          @heroku_app = heroku.get_app(@heroku_appname)
          say "App already created!"
        rescue ::Heroku::API::Errors::NotFound
          say "Name available!"
          @heroku_app = heroku.post_app('name' => @heroku_appname, 'region' => @heroku_region)
          say "Heroku app created!"
        rescue ::Heroku::API::Errors::Forbidden
          say "Name already taken! :("
        end
      end while @heroku_app.blank?

      @heroku_collaborators.each do |email|
        say "Adding #{email} as collaborator"
        heroku.post_collaborator(@heroku_appname, email)
        say "#{email} added as collaborator"
      end

      say "Adding user-env-compile feature..."
      heroku.post_feature('user-env-compile', @heroku_appname)

      git remote: "add heroku #{@heroku_app.body['git_url']}"

      gsub_file "config/environments/production.rb", /Don't fallback to assets pipeline/, "Fallback to assets pipeline"
      gsub_file "config/environments/production.rb", /config\.assets\.compile = false/, "config.assets.compile = true"
      gsub_file "config/environments/production.rb", /config\.serve_static_assets = false/, "config.serve_static_assets = true"
      inject_into_file "config/environments/production.rb", "  config.static_cache_control = 'public, max-age=2592000'\n", after: "config.serve_static_assets = true\n"
      inject_into_file "config/environments/production.rb", "  config.middleware.insert_before ActionDispatch::Static, Rack::Deflater\n", after: "config.serve_static_assets = true\n"
      inject_into_file "config/application.rb", "  config.assets.initialize_on_precompile = false\n", after: "config.assets.enabled = true\n"

      @access_key = ENV['AMAZON_ACCESS_KEY_ID'] || ask("Amazon access key ID: ")
      @access_secret = ENV['AMAZON_SECRET_ACCESS_KEY'] || ask("Amazon secret access key: ")
      @bucket_location = ENV['AMAZON_DEFAULT_BUCKET_LOCATION'] || choose("Bucket location", [["Europe", :eu], ["US", :us]])
      @bucket_location = @bucket_location.to_s.downcase.to_sym
      @bucket_name = ask "Specify S3 bucket name:"

      service = S3::Service.new(access_key_id: @access_key, secret_access_key: @access_secret)
      copy_file "db/migrate/20121126113057_create_asset_thumbs.rb"
      copy_file "config/initializers/dragonfly.rb"

      begin
        @bucket = service.buckets.find(@bucket_name)
        say "Bucket already present!"
      rescue Exception => e
        say e.message
        @bucket = service.buckets.build(@bucket_name)
        @bucket.save(location: @bucket_location)
        say "Bucket created!"
      end

      if yes? "Do you want to create a dedicated AWS user (name '#{@bucket_name}')?"
        iam = AWS::IAM.new(access_key_id: @access_key, secret_access_key: @access_secret)
        user = iam.users.create(@bucket_name)
        policy = AWS::IAM::Policy.from_json(<<JSON
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::#{@bucket_name}",
                "arn:aws:s3:::#{@bucket_name}/*"
            ]
        }
    ]
}
JSON
        )
        user.policies["PersonalBucketAccess"] = policy
        credentials = user.access_keys.create.credentials
        @access_key = credentials[:access_key_id]
        @access_secret = credentials[:secret_access_key]
      end

      fog_regions = {
        eu: 'eu-west-1',
        us: 'us-east-1'
      }

      heroku.put_config_vars(
        @heroku_appname,
        'S3_BUCKET' => @bucket_name,
        'S3_KEY' => @access_key,
        'S3_SECRET' => @access_secret,
        'S3_REGION' => fog_regions[@bucket_location]
      )

      gem 'fog', group: 'production'
      gem 'pg', group: 'production'
      gem 'unicorn'

      copy_file 'config/unicorn.rb'
      copy_file 'Procfile'

      commit_all "Configured Heroku and S3"
    end

    def recap
      say "The app is ready to be deployed on Heroku at #{@heroku_app.body['web_url']} with 'git push heroku master && heroku run rake db:migrate'"
    end

  end
end

