class Catalog < ActiveRecord::Base
  include PhotoServices

  serialize :watch_path, Array
  serialize :sync_from_albums, Array

  has_many :facets, -> { where type: 'CatalogFacet' }, class_name: 'Facet', foreign_key: :source_id
  has_many :photos, through: :facets, foreign_key: :source_id

  # has_many :instances
  # has_many :photos, through: :instances
  has_many :jobs, as: :jobable
  belongs_to  :user


  def cover_url
    if self.photos.count > 0
      self.photos.first.url_md
    else
      Photo.null_photo
    end
  end

  def synchronized
    self.instances.where(:status=>1)
  end

  def not_synchronized
    self.instances - self.synchronized
  end

  def catalogtype
    case self.type
    when "LocalCatalog"
      "Local"
    when "DropboxCatalog"
      "Dropbox"
    when "FlickrCatalog"
      "Flickr"
    when "MasterCatalog"
      "Master"
    end
  end

  def self.master
    Rails.cache.fetch("master_catalog", expires_in: 12.hours) do
      self.where(default:true).first
    end
  end

end
