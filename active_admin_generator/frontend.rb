module ::ActiveAdminGenerator
  class Frontend < Base
    def apply!
      gem "slim-rails"
      gem "compass-rails"
      gem "sextant"

      apply_high_voltage!

      commit_all "Added frontend gems"
    end

    def apply_high_voltage!
      gem "high_voltage"

      copy_file "config/initializers/high_voltage.rb"
      copy_file "app/controllers/static_controller.rb"
      empty_directory "app/views/static"
      copy_file "app/views/static/homepage.html.slim"

    end
  end
end



