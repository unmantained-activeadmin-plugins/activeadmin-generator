require 'mechanize'
require 'uri'

module ::Bricks
  class Errbit < Base

    def apply?
      yes? "Do you want to configure Errbit?"
    end

    def before_bundle
      gem 'airbrake'

      ask_name_and_collaborators

      @errbit_url = ENV['ERRBIT_URL'] || ask("Errbit URL")
      uri = URI(@errbit_url)

      @errbit_host = uri.host
      @errbit_port = uri.scheme == "https" ? 443 : 80

      @errbit_email = ENV['ERRBIT_EMAIL'] || ask("Errbit email")
      @errbit_password = ENV['ERRBIT_PASSWORD'] || ask("Errbit password")

      login!
      @api_key = find_app_key

      while @api_key.blank?
        begin
          @api_key = create_app_key
        rescue RuntimeError => e
          say e.message
          ask_name_and_collaborators
        end
      end

      template "config/initializers/errbit.rb"
    end

    def ask_name_and_collaborators(force = false)
      @app_name = ENV['APP_NAME']
      @collaborators = ( ENV['ERRBIT_COLLABORATORS'] || ask("Specify collaborators' User IDs:") ).split(/\s*,\s*/).map(&:strip)
    end

    def agent
      @agent ||= Mechanize.new
    end

    def login!
      agent.get(abs_path('/users/sign_in')) do |page|
        page.form_with(action: '/users/sign_in') do |f|
          f["user[email]"] = @errbit_email
          f["user[password]"] = @errbit_password
        end.submit
      end
    end

    def fetch_api_key(page)
      page.search("span.meta").text.gsub(/^.*API Key:/m, '').strip
    rescue
      nil
    end

    def find_app_key
      page = agent.get(abs_path('/apps'))
      link = page.search("td.name a").find { |link| link.text == @app_name }
      link.present? ? fetch_api_key(agent.get(link["href"])) : nil
    end

    def create_app_key
      new_page = agent.get(abs_path('/apps/new'))
      result_page = new_page.form_with(action: '/apps') do |f|
        f["app[name]"] = @app_name
        f["app[notify_on_errs]"] = "1"
        @collaborators.each_with_index do |uid, i|
          f["app[watchers_attributes][#{i}][user_id]"] = uid
        end
      end.submit

      api_key = fetch_api_key(result_page)

      if api_key.nil?
        fail result_page.search(".error-messages ul li").map(&:text).join("\n")
      end

      api_key
    end

    def abs_path(path)
      @errbit_url + path
    end

  end
end

