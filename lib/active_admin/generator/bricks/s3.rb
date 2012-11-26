require 's3'

module ::Bricks
  class Frontend < Base

    attr_reader :access_key, :access_secret, :bucket_name

    def apply?
      yes? "Do you want to create an S3 bucket?"
      @access_key = ENV['AMAZON_ACCESS_KEY_ID'] || ask("Amazon access key ID: ")
      @access_secret = ENV['AMAZON_SECRET_ACCESS_KEY'] || ask("Amazon secret access key: ")
      @bucket_location = ENV['AMAZON_DEFAULT_BUCKET_LOCATION'] || choose("Bucket location", [["Europe", :eu], ["US", :us]])
    end

    def before_bundle
      @bucket_name = ask "What's the S3 bucket name?"
      service = S3::Service.new(access_key_id: @access_key, secret_access_key: @access_secret)
      begin
        @bucket = service.buckets.find(@bucket_name)
        say "Bucket already present!"
      rescue S3::Error::NoSuchBucket
        @bucket = service.buckets.build(@bucket_name)
        @bucket.save(location: @bucket_location.to_s.downcase.to_sym)
        say "Bucket created!"
      end
    end

  end
end

