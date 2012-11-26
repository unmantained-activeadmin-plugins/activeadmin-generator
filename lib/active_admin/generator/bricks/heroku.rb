module ::Bricks
  class Heroku < Base

    def apply?
      yes? "Do you want to deploy this site on Heroku?"
    end

    def before_bundle
      copy_file "db/migrate/20121126113057_create_asset_thumbs.rb"
      copy_file "config/initializers/dragonfly.rb"
    end

    def after_bundle
      rake "activeadmin_gallery:install:migrations"
      rake "activeadmin_wysihtml5:install:migrations"
      rake "activeadmin_seo:install:migrations"
    end

  end
end





