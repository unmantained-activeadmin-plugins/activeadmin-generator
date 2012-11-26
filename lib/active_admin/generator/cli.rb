require 'thor'
require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module ActiveAdmin
  module Generator
    class CLI < Thor

      desc "new", "Bootstraps a new ActiveAdmin project"
      def new(name)
        ARGV.shift(ARGV.count)
        ARGV.unshift name, '-T', '-m', File.join(File.dirname(__FILE__), "base.rb"), '--trace'
        Rails::Generators::AppGenerator.start
      end

    end
  end
end


