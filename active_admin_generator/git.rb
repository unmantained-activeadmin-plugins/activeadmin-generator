module ::ActiveAdminGenerator
  class Git < Base
    def apply!
      git :init

      append_file ".gitignore", <<-END
      *.swp
      .sass-cache
      root.dir
      .rake_tasks~
      db/schema.rb
      public/system
      END

      commit_all "First commit"
    end
  end
end

