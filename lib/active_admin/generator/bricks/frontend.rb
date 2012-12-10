module ::Bricks
  class Frontend < Base
    def before_bundle
      gem "rails-i18n"
      gem "slim-rails"
      gem "compass-rails"
      gem "sextant"
      gem "modernizr-rails"
      gem "hive-rails", github: 'stefanoverna/hive-rails', branch: 'master'
      commit_all "Added frontend gems"

      remove_dir 'app'
      directory 'app'
      route "root to: 'static#homepage'"

      commit_all "Added basic frontend skeleton"

      apply_i18n_routes!
    end

    def deflate_assets
      copy_file "config.ru"
    end

    def apply_i18n_routes!
      gem 'i18n_routing'
      copy_file "config/locales/it.yml"
      commit_all "Added i18n routes"
    end

  end
end



