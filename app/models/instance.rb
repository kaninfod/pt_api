class Instance < ActiveRecord::Base

  belongs_to :facet
  has_one :photo, through: :facet
  has_one :catalog, through: :facet

  before_destroy :delete_photo

  def delete_photo
    if self.instance_type == "dropbox"
      DeleteDropboxPhotoFromCatalog.perform_later self.photo_id, self.catalog.access_token
    elsif self.instance_type == "flickr"
      keys = {
        access_token: self.catalog.access_token,
        oauth_token_secret: self.catalog.oauth_token_secret,
        appkey: self.catalog.appkey,
        appsecret: self.catalog.appsecret,
      }
      DeleteFlickrPhotoFromCatalog.perform_later self.photo_id, keys
    end

  end
end
