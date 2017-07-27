class Album < ActiveRecord::Base
  serialize :photo_ids, Array
  serialize :tags, Array
  has_and_belongs_to_many :photos, -> { distinct }
  validates :name, presence: true

  def count
    return photos.count
  end

  def cover_url
    if self.album_photos.count > 0
      self.album_photos.first.url('md')
    else
      Photo.null_photo
    end
  end

  def add_photos(photo_ids)
      if photo = Photo.where(id: photo_ids)
        self.photos << photo unless self.photos.include?(photo_ids)
      end
  end

  def album_photos
    result = Photo
                .joins(join_location)
                .joins(join_tagging)
                .joins(join_vote)
                .joins(join_album_photo)
                .where(conditions)
                .distinct(:id)
    # result_p = self.photos
    # result_p + result
  end

  def conditions
    exp = false
    expressions = [
      [:_start_date,     "and"],
      [:_end_date,       "and"],
      [:_country,   "and"],
      [:_city,      "and"],
      [:_make,      "and"],
      [:_tagging,   "and"],
      [:_vote,      "and"],
      [:_album,     "or"],
      # [:_photo_ids,  "or"]
    ]

    expressions.each do |method, operator|
      n = send(method)
      if n != nil
        if !exp
          exp = n
        else
          if operator == "and"
            exp = exp.and(n)
          elsif operator == "or"
            exp = exp.or(n)
          end
        end
      end
    end
    return exp
  end


  def _start_date
    t_photo[:date_taken].gteq(self.start_date) unless self.start_date.blank?
  end

  def _end_date
    t_photo[:date_taken].lteq(self.end_date) unless self.end_date.blank?
  end

  def _country
    t_location[:country_id].eq(self.country) unless (self.country.blank? || self.country == "-1")
  end

  def _city
    t_location[:city_id].eq(self.city) unless (self.city.blank? || self.city == "-1")
  end

  def _make
    t_photo[:make].eq(self.make) unless self.make.blank?
  end

  # def _photo_ids
  #   t_photo[:id].in(self.photo_ids) unless self.photo_ids.length == 0
  # end

  def _tagging
    t_tagging[:tag_id].in(self.tags) unless self.tags.length == 0
  end

  def _vote
    if self.like == true
      t_vote[:votable_id].gt(0)
    end
  end

  def _album
    t_album_photo[:album_id].eq(self.id) unless self.id.blank?
  end

  def join_location
    constraint_location = t_photo.create_on(t_photo[:location_id].eq(t_location[:id]))
    t_photo.create_join(t_location, constraint_location, Arel::Nodes::InnerJoin)
  end

  def join_tagging
    constraint_tagging = t_photo.create_on(t_photo[:id].eq(t_tagging[:taggable_id]))
    t_photo.create_join(t_tagging, constraint_tagging, Arel::Nodes::OuterJoin)
  end

  def join_vote
    constraint_vote = t_vote.create_on(t_photo[:id].eq(t_vote[:votable_id]))
    t_photo.create_join(t_vote, constraint_vote, Arel::Nodes::OuterJoin)
  end

  def join_album_photo
    constraint_album_photo = t_album_photo.create_on(t_photo[:id].eq(t_album_photo[:photo_id]))
    t_photo.create_join(t_album_photo, constraint_album_photo, Arel::Nodes::OuterJoin)
  end

  def t_album_photo
    Arel::Table.new("albums_photos")
  end

  def t_photo
    Photo.arel_table
  end

  def t_location
    Location.arel_table
  end

  def t_vote
    Vote.arel_table
  end

  def t_tagging
    Tagging.arel_table
  end


  # def photos
  #
  #   if not self.start.blank?
  #     date_start = self.start.to_datetime
  #     p_start = get_predicate('date_taken', date_start, :gteq)
  #     exp = p_start
  #   end
  #
  #   if not self.end.blank?
  #     date_end = self.end.to_time + 25.hours - 1.seconds
  #     p_end = get_predicate('date_taken', date_end, :lteq)
  #     if not exp.blank?
  #       exp = exp&p_end
  #     else
  #       exp= p_end
  #     end
  #   end
  #
  #   if not self.make.blank?
  #     p_make = get_predicate('make', self.make, :eq)
  #     if not exp.blank?
  #       exp = exp&p_make
  #     else
  #       exp = p_make
  #     end
  #   end
  #
  #   if not self.model.blank?
  #     p_model = get_predicate('model', self.model, :eq)
  #     if not exp.blank?
  #       exp = exp&p_model
  #     else
  #       exp = p_model
  #     end
  #   end
  #
  #   location_stub = Squeel::Nodes::Stub.new(:location)
  #
  #   if not self.country.blank?
  #     p_country = get_predicate(:country, self.country, :eq)
  #     k_country = Squeel::Nodes::KeyPath.new([location_stub, p_country])
  #     if not exp.blank?
  #       exp = exp&k_country
  #     else
  #       exp = k_country
  #     end
  #   end
  #
  #   if not self.city.blank?
  #     p_city = get_predicate('city', self.city, :eq)
  #     k_city = Squeel::Nodes::KeyPath.new([location_stub, p_city])
  #     if not exp.blank?
  #       exp = exp&k_city
  #     else
  #       exp = k_city
  #     end
  #   end
  #
  #   if not self.photo_ids.blank?
  #     p_photo_ids = get_predicate('id', self.photo_ids, :in)
  #     if not exp.blank?
  #       exp = exp|p_photo_ids
  #     else
  #       exp = p_photo_ids
  #     end
  #   end
  #
  #   Photo.joins(:location).where(exp)
  #
  # end

  def self.generate_year_based_albums
    distinct_years = Photo.pluck(:date_taken).map{|x| x.year}.uniq.each do |rec|
      album = Album.new
      album.name =  rec.to_s
      album.start_date = Date.new(rec.to_i, 1, 1)
      album.end_date = Date.new(rec.to_i, 12, 31)
      album.album_type = "year"
      album.save
    end
  end

  def self.generate_month_based_albums
    distinct_months = Photo.pluck(:date_taken).map{|x| Date.new(x.year, x.month, 1)}.uniq.each do |rec|
      album = Album.new
      album.name = rec.strftime("%b %Y").to_s
      album.start_date = rec
      album.end_date = (rec >> 1) -1
      album.album_type = "month"
      album.save
    end
  end

  def self.generate_inteval_based_albums(inteval=10, density=10)
    inteval = inteval*60
    albums=[]

    Photo.all.order(:date_taken).each do |photo|

      flag ||= false
      albums.each do |serie|
        if photo.date_taken < (serie.max + inteval) and photo.date_taken > (serie.min - inteval)
          serie.push  photo.date_taken
          flag ||= true
        end
      end

      albums.push [photo.date_taken] unless flag
    end


    albums.delete_if do |album|

      if album.count < density
        true
      else
        new_album = self.new
        new_album.name = album.min.strftime("%b %Y %d").to_s
        new_album.start_date = album.min
        new_album.end_date = album.max
        new_album.album_type = "event"
        new_album.save
        false
      end
    end

    return albums
  end

  private
  #
  # def get_predicate(col, value, predicate)
  #   Squeel::Nodes::Predicate.new(Squeel::Nodes::Stub.new(col), predicate, value)
  # end
end
