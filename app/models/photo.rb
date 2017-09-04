class Photo < ActiveRecord::Base
  validate :date_taken_is_valid_datetime

  before_update :move_by_date, if: :date_taken_changed?

  belongs_to :location, default: -> { Location.no_location }

  has_many :facets, dependent: :destroy
  has_many :tag_facets
  has_one  :bucket_facet
  has_one  :like_facet
  has_many :comment_facets
  has_many :album_facets
  has_many :catalog_facets

  has_many :catalogs, through: :catalog_facets, foreign_key: :source_id
  has_many :albums, through: :album_facets, foreign_key: :source_id
  has_many :tags, through: :tag_facets, foreign_key: :source_id
  has_many :comments, through: :comment_facets, foreign_key: :source_id

  has_many :jobs, as: :jobable

  reverse_geocoded_by :latitude, :longitude

  attr_accessor :import_path

  scope :distinct_models, -> {
    ary = select(:model).distinct.map { |c| [c.model] }.unshift([''])
    ary.delete([nil])
    ary.sort_by{|el| el[0] }
  }
  scope :distinct_makes, -> {
    ary = select(:make).distinct.map { |c| [c.make] }.unshift([''])
    ary.delete([nil])
    ary.sort_by{|el| el[0] }
  }

  def bucket_toggle(user)
    _bucket = BucketFacet.where(photo: self, user: user)
    if _bucket.present?
      _bucket.first.destroy
    else
      BucketFacet.create(photo: self, user: user)
    end
    self
  end

  def like_toggle(user)
    _like = LikeFacet.where(photo: self, user: user)
    if _like.present?
      _like.first.destroy
    else
      LikeFacet.create(photo: self, user: user)
    end
    self
  end

  def add_comment(user, comment)
    CommentFacet.create(
      photo: self,
      user: user,
      comment: Comment.find_or_create_by(name: comment)
    )
  end

  def uncomment(facet_id)
    _comment = CommentFacet.where(photo: self, id: facet_id)
    if _comment.present?
      _comment.first.destroy
    end
  end

  def add_tag(user, tag)
    TagFacet.create(
      photo: self,
      user: user,
      tag: Tag.find_or_create_by(name: tag)
    )
  end

  def untag(facet_id)
    _tag = TagFacet.where(photo: self, id: facet_id)
    if _tag.present?
      _tag.first.destroy
    end
  end

  def date_taken_is_valid_datetime
    if ((DateTime.parse(date_taken.to_s) rescue ArgumentError) == ArgumentError)
      errors.add(:date_taken, 'must be a valid datetime')
    end
  end

  def date_taken_formatted
    date_taken.strftime("%b %d %Y %H:%M:%S")
  end

  def delete
    DeletePhoto.perform_later self.id
    self.update(status: 1)
  end

  def coordinate_string
    self.latitude.to_s + "," + self.longitude.to_s
  end

  def catalog(catalog_id=Catalog.master.id)
    self.catalogs.where{id.eq(catalog_id)}.first
  end

  def get_photofiles_hash
    hash = {
      :original=>self.org_id,
      :large=>self.lg_id,
      :medium=>self.md_id,
      :thumb=>self.tm_id,
    }
    return hash
  end

  def self.null_photo
    id = Setting.generic_image_md_id
    "/api/photofiles/#{id}/photoserve"
  end

  def similar(similarity=1, count=3)
    Photo.where("HAMMINGDISTANCE(#{self.phash}, phash) < ?", similarity)
      .limit(count)
      .order("HAMMINGDISTANCE(#{self.phash}, phash)")
  end

  def similarity(photo)
    Phashion.hamming_distance(photo.phash.to_i, self.phash.to_i)
  end

  def identical()
    identical_photos = similar 1, 1
    if identical_photos.count > 0
      true
    end
  end

  def self.exists(phash)
    res = Photo.where("HAMMINGDISTANCE(#{phash}, phash) < ?", 1).limit(1)
    if res.length == 1
      return true
    else
      return false
    end

  end

  def locate
    UtilLocator.perform_later self.id
  end

  def rotate(degrees)
    PhotoRotate.perform_later self.id, degrees.to_i
    self.update(status: 6)
  end

  def url_tm
    "/api/photofiles/#{self.send("tm_id")}/photoserve"
  end

  def url_md
    "/api/photofiles/#{self.send("md_id")}/photoserve"
  end

  def url_lg
    "/api/photofiles/#{self.send("lg_id")}/photoserve"
  end

  def url_org
    "/api/photofiles/#{self.send("org_id")}/photoserve"
  end

  def add_to_album(album_id)
    if Album.where(id: album_id).first
      album = Album.find(album_id)
      album.photos << self
    end
  end

  private
    def move_by_date
      PhotoMoveByDate.perform_later self.id
    end
end
