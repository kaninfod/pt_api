class Album < ActiveRecord::Base
  serialize :photo_ids, Array
  serialize :tags, Array
  has_and_belongs_to_many :photos, -> { distinct }
  validates :name, presence: true
  after_initialize :set_default_values

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
                .joins(join_album_photo)
                .joins(join_facet)
                .where(conditions)
                .distinct(:id)

                # .joins(join_vote)
    # result_p = self.photos
    # result_p + result
  end

  def conditions
    photo_rules = [
      { :operator => "and", :method => :_start_date },
      { :operator => "and", :method => :_start_date },
      { :operator => "and", :method => :_end_date   },
      { :operator => "and", :method => :_country    },
      { :operator => "and", :method => :_city       },
      { :operator => "and", :method => :_make       },
      { :operator => "or" , :method => :_album      },
    ]

    facet_rules = [
      { :operator => "and", :method => :_like       },
      { :operator => "or" , :method => :_has_comment},
    ]

    photo = process_rules(photo_rules)
    facet = process_rules(facet_rules)

    if !facet
        expression = photo
    else
      expression = photo.and(facet)
    end

    return expression
  end

  def process_rules(rules)
    exp = false
    rules.each do |rule|
      res = send(rule[:method])
      if res != nil
        if !exp
          exp = res
        else
          if rule[:operator] == "and"
            exp = exp.and(res)
          elsif rule[:operator] == "or"
            exp = exp.or(res)
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

  def _tagging
    t_tagging[:tag_id].in(self.tags) unless self.tags.length == 0
  end

  def _like
    t_facet[:type].eq("Like") unless self.like == false
  end

  def _has_comment
    t_facet[:type].eq("Comment") unless self.has_comment == false
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

  def join_facet
    constraint_facet = t_facet.create_on(t_photo[:id].eq(t_facet[:photo_id]))
    t_photo.create_join(t_facet, constraint_facet, Arel::Nodes::OuterJoin)
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

  def t_facet
    Facet.arel_table
  end

  def t_tagging
    Tagging.arel_table
  end

  private
    def set_default_values
      self.like ||= false
      self.has_comment ||= false
    end

  # def self.generate_year_based_albums
  #   distinct_years = Photo.pluck(:date_taken).map{|x| x.year}.uniq.each do |rec|
  #     album = Album.new
  #     album.name =  rec.to_s
  #     album.start_date = Date.new(rec.to_i, 1, 1)
  #     album.end_date = Date.new(rec.to_i, 12, 31)
  #     album.album_type = "year"
  #     album.save
  #   end
  # end
  #
  # def self.generate_month_based_albums
  #   distinct_months = Photo.pluck(:date_taken).map{|x| Date.new(x.year, x.month, 1)}.uniq.each do |rec|
  #     album = Album.new
  #     album.name = rec.strftime("%b %Y").to_s
  #     album.start_date = rec
  #     album.end_date = (rec >> 1) -1
  #     album.album_type = "month"
  #     album.save
  #   end
  # end
  #
  # def self.generate_inteval_based_albums(inteval=10, density=10)
  #   inteval = inteval*60
  #   albums=[]
  #
  #   Photo.all.order(:date_taken).each do |photo|
  #
  #     flag ||= false
  #     albums.each do |serie|
  #       if photo.date_taken < (serie.max + inteval) and photo.date_taken > (serie.min - inteval)
  #         serie.push  photo.date_taken
  #         flag ||= true
  #       end
  #     end
  #
  #     albums.push [photo.date_taken] unless flag
  #   end
  #
  #
  #   albums.delete_if do |album|
  #
  #     if album.count < density
  #       true
  #     else
  #       new_album = self.new
  #       new_album.name = album.min.strftime("%b %Y %d").to_s
  #       new_album.start_date = album.min
  #       new_album.end_date = album.max
  #       new_album.album_type = "event"
  #       new_album.save
  #       false
  #     end
  #   end
  #
  #   return albums
  # end
end
