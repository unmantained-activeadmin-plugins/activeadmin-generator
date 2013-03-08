require 'uri'
require 'dragonfly'
begin
  require 'rack/cache'
rescue LoadError => e
  puts "Couldn't find rack-cache - make sure you have it in your Gemfile:"
  puts "  gem 'rack-cache', :require => 'rack/cache'"
  puts " or configure dragonfly manually instead of using 'dragonfly/rails/images'"
  raise e
end

app = Dragonfly[:images]
app.configure_with(:rails)
app.configure_with(:imagemagick)

if defined?(ActiveRecord::Base)
  app.define_macro(ActiveRecord::Base, :image_accessor)
  app.define_macro(ActiveRecord::Base, :file_accessor)
end

rack_cache_already_inserted = Rails.application.config.action_controller.perform_caching && Rails.application.config.action_dispatch.rack_cache

Rails.application.middleware.insert 0, Rack::Cache, {
  :verbose     => true,
  :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
  :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
} unless rack_cache_already_inserted

Rails.application.middleware.insert_after Rack::Cache, Dragonfly::Middleware, :images

class AssetThumb < ActiveRecord::Base
  attr_accessible :job, :uid
  before_destroy do |thumb|
    Dragonfly[:images].datastore.destroy(thumb.uid)
  end
end

if ENV['S3_BUCKET']
  app.cache_duration = 3600*24*365*3
  app.configure do |c|
    c.define_url do |app, job, opts|
      thumb = AssetThumb.find_by_job(job.serialize)
      if !thumb
        uid = job.store
        thumb = AssetThumb.create!(uid: uid, job: job.serialize)
      end
      app.datastore.url_for(thumb.uid)
    end
  end
  app.datastore = Dragonfly::DataStorage::S3DataStore.new
  app.datastore.configure do |c|
    c.bucket_name = ENV['S3_BUCKET']
    c.access_key_id = ENV['S3_KEY']
    c.secret_access_key = ENV['S3_SECRET']
    c.region = ENV['S3_REGION']
  end
end

