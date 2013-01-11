module ::Bricks
  class Frontend < Base
    def before_bundle
      gem "rails-i18n"
      gem "slim-rails"
      gem "compass-rails", group: :assets
      gem "sextant", group: :development
      gem "modernizr-rails", group: :assets
      gem "hive-rails", github: 'stefanoverna/hive-rails', branch: 'master'
      gem "sprockets-image_compressor", group: :production
      commit_all "Added frontend gems"

      remove_dir 'app'
      directory 'app'
      route "root to: 'static#homepage'"

      commit_all "Added basic frontend skeleton"

      apply_i18n_routes!
      apply_letter_opener!
    end

    def apply_i18n_routes!
      gem 'i18n_routing'
      copy_file "config/locales/it.yml"
      commit_all "Added i18n routes"
    end

    def apply_letter_opener!
      inject_into_file "config/environments/development.rb", "  config.action_mailer.delivery_method = :letter_opener\n", after: "config.assets.debug = true\n"
    end

  end
end



