module ::ActiveAdminGenerator
  class CleanAssets < Base
    def apply!
      remove_file 'public/index.html'
      remove_file 'app/assets/images/rails.png'

      commit_all "Removed Rails default assets"
    end
  end
end


