class Photo < ActiveRecord::Base
  validate :date_taken_is_valid_datetime

  before_destroy :_delete
  before_update :move_by_date, if: :date_taken_changed?

  has_and_belongs_to_many :albums
  belongs_to :location, default: -> { Location.no_location }
  has_many :instances
  has_many :catalogs, through: :instances
  has_many :facets
  has_many :tags
  has_one  :bucket
  has_one  :like
  has_many :comments

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
  scope :years, -> {
    sql = "select distinct(year(date_taken)) as value from photos order by value;"
    find_by_sql(sql)
  }
  scope :months, -> (year) {
    sql = "select distinct(month(date_taken)) as value from photos where year(date_taken) = #{year} order by value;"
    find_by_sql(sql)
  }
  scope :days, -> (year, month) {
    sql = "select distinct(day(date_taken)) as value from photos where year(date_taken) = #{year} and month(date_taken) = #{month} order by value;"
    find_by_sql(sql)
  }

  def add_bucket(user)
    Bucket.create(photo: self, user: user)
    self
  end

  def unbucket(user)
    if Bucket.where(photo: self, user: user).present?
      Bucket.where(photo: self, user: user).first.destroy
    end
    self
  end

  def add_like(user)
    Like.create(photo: self, user: user)
  end

  def unlike(user)
    if Like.where(photo: self, user: user).present?
      Like.where(photo: self, user: user).first.destroy
    end
  end

  def add_comment(user, comment)
    Comment.create(
      photo: self,
      user: user,
      source_comment: SourceComment.create(name: comment)
    )
  end

  def uncomment(facet_id)
    _comment = Comment.where(photo: self, id: facet_id)
    if _comment.present?
      _comment.first.destroy
    end
  end

  def add_tag(user, tag)
    Tag.create(
      photo: self,
      user: user,
      source_tag: SourceTag.find_or_create_by(name: tag)
    )
  end

  def untag(facet_id)
    _tag = Tag.where(photo: self, id: facet_id)
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

    def _delete
      #Always call destroy!! this is called by the callback.
      begin
        self.instances.each do |instance|
          instance.destroy
        end
      rescue Exception => e
        logger.debug "#{e}"
      end
    end


end


# def add_comment(new_comment, user_id)
#   puts "new_comment #{new_comment}"
#   comment = self.comments.create
#   comment.comment = new_comment
#   comment.user_id = user_id
#   comment.save
#
#   self.objective_list.add new_comment.scan(/(^\#\w+|(?<=\s)\#\w+)/).join(',')
#   self.tag_list.add new_comment.scan(/(^\@\w+|(?<=\s)\@\w+)/).join(',')
#   self.save
#   return comment
# end
#
# def add_tag(tag)
#
#   if tag[0,1] == "@"
#     self.objective_list.add tag
#   else
#     self.tag_list.add tag
#   end
#
#   if self.save
#     return true
#   else
#     return false
#   end
# end
#
# def remove_tag(tag)
#
#   if tag[0,1] == "@"
#     self.objective_list.remove tag
#   else
#     self.tag_list.remove tag
#   end
#
#   if self.save
#     return true
#   else
#     return false
#   end
# end
