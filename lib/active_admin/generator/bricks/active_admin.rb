module ::Bricks
  class ActiveAdmin < Base
    def before_bundle
      gem 'activeadmin', github: 'gregbell/active_admin'
      gem 'ransack'
      gem "devise-i18n"
      @site_title = ENV['APP_NAME']
    end

    def after_bundle
      generate 'active_admin:install'
      remove_file "config/initializers/active_admin.rb"
      template "config/initializers/active_admin.rb"
      commit_all "ActiveAdmin installed"
    end

    def recap
      say 'Run rails server, visit http://127.0.0.1:3000/admin and log in using:'
      say 'admin@example.com'
      say 'password'
    end
  end
end

