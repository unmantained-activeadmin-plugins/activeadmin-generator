module ::Bricks
  class Git < Base
    def before_bundle
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

