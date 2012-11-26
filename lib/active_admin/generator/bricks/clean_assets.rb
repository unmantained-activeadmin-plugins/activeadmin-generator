module ::Bricks
  class CleanAssets < Base
    def before_bundle
      remove_file 'public/index.html'
      remove_file 'app/assets/images/rails.png'

      commit_all "Removed Rails default assets"
    end
  end
end


