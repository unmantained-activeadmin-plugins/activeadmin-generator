module ::Bricks
  class ActiveAdminExtras < Base

    def before_bundle
      gem 'activeadmin-dragonfly', github: 'stefanoverna/activeadmin-dragonfly', branch: 'master'
      gem 'activeadmin-globalize3', github: 'stefanoverna/activeadmin-globalize3', branch: 'master'
      gem 'activeadmin-wysihtml5', github: 'stefanoverna/activeadmin-wysihtml5', branch: 'master'
      gem 'activeadmin-gallery', github: 'stefanoverna/activeadmin-gallery', branch: 'master'
      gem 'activeadmin-extra', github: 'stefanoverna/activeadmin-extra', branch: 'master'
      gem 'activeadmin-seo', github: 'nebirhos/activeadmin-seo', branch: 'master'

      commit_all "Added ActiveAdmin extra gems"
    end

    def after_bundle
      rake "activeadmin_gallery:install:migrations"
      rake "activeadmin_wysihtml5:install:migrations"
      rake "activeadmin_seo:install:migrations"

      remove_file "app/assets/stylesheets/active_admin.css.scss"
      copy_file "app/assets/stylesheets/active_admin.css.sass"

      commit_all "Run ActiveAdmin customizations"
    end

  end
end




