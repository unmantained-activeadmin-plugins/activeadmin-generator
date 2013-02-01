class AssetThumb < ActiveRecord::Base
  attr_accessible :job, :uid

  before_destroy do |thumb|
    Dragonfly[:images].datastore.destroy(thumb.uid)
  end
end
