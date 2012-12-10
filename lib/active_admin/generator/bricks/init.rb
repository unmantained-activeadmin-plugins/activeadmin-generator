module ::Bricks
  class Init < Base

    def before_bundle
      say "=" * 80
      say "Welcome to ActiveAdmin Generator! :)".center(80) + "\n"
      say "=" * 80
      ENV['APP_NAME'] = ask("Name of the project:")
    end

  end
end




