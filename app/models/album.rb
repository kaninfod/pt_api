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
      self.album_photos.first.url_md
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
                .joins(join_sourcetag)
                .joins(join_sourcecomment)
                .where(conditions)
                .distinct(:id)
  end

  def conditions
    photo_rules = [
      { :operator => :and, :method => :_start_date },
      { :operator => :and, :method => :_start_date },
      { :operator => :and, :method => :_end_date   },
      { :operator => :and, :method => :_country    },
      { :operator => :and, :method => :_city       },
      { :operator => :and, :method => :_make       },
      { :operator => :or , :method => :_album      },
    ]

    facet_rules = [
      { :operator => :or , :method => :_has_comment},
      { :operator => :or,  :method => :_like       },
      { :operator => :or , :method => :_tag},

    ]

    photo = process_rules(photo_rules)
    facet = process_rules(facet_rules)

    if !facet
        expression = photo
    else
      expression = photo.or(facet)
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
          if rule[:operator] == :and
            exp = exp.and(res)
          elsif rule[:operator] == :or
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

  def _tag
    t_sourcetag[:name].in(self.tags).and(t_facet[:type].eq('Tag')) unless self.tags.length == 0
  end

  def _like
    t_facet[:type].eq("Like") unless self.like == false
  end

  def _has_comment
    t_sourcecomment[:name].matches("%#{self.has_comment}%").and(t_facet[:type].eq("Comment")) unless self.has_comment == false
  end

  def _album
    t_album_photo[:album_id].eq(self.id) unless self.id.blank?
  end

  def join_location
    constraint_location = t_photo.create_on(t_photo[:location_id].eq(t_location[:id]))
    t_photo.create_join(t_location, constraint_location, Arel::Nodes::InnerJoin)
  end


  def join_facet
    constraint_facet = t_facet.create_on(t_photo[:id].eq(t_facet[:photo_id]))
    t_photo.create_join(t_facet, constraint_facet, Arel::Nodes::OuterJoin)
  end

  def join_sourcetag
    constraint_sourcetag = t_sourcetag.create_on(t_facet[:source_tag_id].eq(t_sourcetag[:id]))
    t_facet.create_join(t_sourcetag, constraint_sourcetag, Arel::Nodes::OuterJoin)
  end

  def join_sourcecomment
    constraint_sourcecomment = t_sourcecomment.create_on(t_facet[:source_comment_id].eq(t_sourcecomment[:id]))
    t_facet.create_join(t_sourcecomment, constraint_sourcecomment, Arel::Nodes::OuterJoin)
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

  def t_sourcetag
    Arel::Table.new("source_tags")
  end

  def t_sourcecomment
    Arel::Table.new("source_comments")
  end

  private
    def set_default_values
      self.like ||= false
      self.has_comment ||= false
    end

  end
