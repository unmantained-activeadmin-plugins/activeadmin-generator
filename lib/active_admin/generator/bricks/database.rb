module ::Bricks
  class Database < Base

    def before_bundle
      remove_file "config/database.yml"
      gsub_file 'Gemfile', /gem 'sqlite3'\n/, ''

      @adapter = choose "Database used in development?", [["SQLite", :sqlite], ["PostgreSQL", :pg], ["MySQL", :mysql]]

      if @adapter != :sqlite
        @database = ask "Development database name:"
        @username = ask "Username:"
        @password = ask "Password:"
      end

      send("configure_#{@adapter}")
      template "config/database.yml"
      commit_all "Database configured"
    end

    def after_bundle
      rake "db:drop"
      rake "db:create"
    end

    def configure_sqlite
      gem 'sqlite3', group: 'development'
    end

    def configure_mysql
      gem 'mysql2', group: 'development'
    end

    def configure_pg
      gem 'pg', group: 'development'
    end

  end
end






