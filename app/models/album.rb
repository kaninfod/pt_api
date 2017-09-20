class Album < ActiveRecord::Base
  serialize :tags, Array

  has_many :facets, -> { where type: 'AlbumFacet' }, foreign_key: :source_id
  has_many :photos, through: :facets, foreign_key: :source_id

  validates :name, presence: true
  after_initialize :set_default_values

  def album_photos
    @conditions = nil
    append_condition(_start_date)
    append_condition(_end_date)
    append_condition(t_photo[:status].not_eq(1))

    if !(self.country.blank? || self.country == "-1")
      append_condition(location_condition)
    end


    if !self.tags.empty?
      append_condition(tag_condition)
    end

    if self.has_comment
      append_condition(comment_condition)
    end

    if self.id
      append_condition(album_condition, false)
    end

    if self.like
      append_condition(like_condition)
    end

    result = Photo.where(@conditions)
    return result

  end

  def append_condition(new_condition, and_operator=true)
    if !@conditions
      @conditions = new_condition
    else
      if and_operator
        @conditions = @conditions.and(new_condition)
      else
        @conditions = @conditions.or(new_condition)
      end
    end
  end

  def photo_facet_join
    t_photo[:id].eq(t_facet[:photo_id])
  end

  def tag_condition
    tag_ids = Tag.where(name: self.tags).pluck(:id)
    _condition = t_facet[:source_id].in(tag_ids).and(t_facet[:type].eq('TagFacet'))
    t_facet.project('1').where(photo_facet_join.and(_condition)).exists
  end

  def album_condition
    _condition = t_facet[:source_id].eq(self.id).and(t_facet[:type].eq('AlbumFacet'))
    t_facet.project('1').where(photo_facet_join.and(_condition)).exists
  end

  def like_condition
    _condition = t_facet[:type].eq('LikeFacet')
    t_facet.project('1').where(photo_facet_join.and(_condition)).exists
  end

  def comment_condition
    _condition = t_facet[:type].eq('CommentFacet')
    t_facet.project('1').where(photo_facet_join.and(_condition)).exists
  end

  def location_condition
    if !(self.city.blank? || self.city == "-1")
      location_id = Location.find_by(city: self.city.to_i).id
    elsif !(self.country.blank? || self.country == "-1")
      location_id = Location.find_by(country: self.country.to_i).id
    end
    _condition = t_facet[:source_id].eq(location_id).and(t_facet[:type].eq('LocationFacet'))
    t_facet.project('1').where(photo_facet_join.and(_condition)).exists
  end

  def facet(type, source_id)
    _condition = t_facet[:source_id].eq(source_id).and(t_facet[:type].eq(type))
    t_facet.project('1').where(photo_facet_join.and(_condition))
  end

  def _start_date
    t_photo[:date_taken].gteq(self.start_date) unless self.start_date.blank?
  end

  def _end_date
    t_photo[:date_taken].lteq(self.end_date) unless self.end_date.blank?
  end

  def _make
    t_photo[:make].eq(self.make) unless self.make.blank?
  end

  def _tag
    t_tag[:name].in(self.tags).and(t_facet[:type].eq('Tag')) unless self.tags.length == 0
  end

  def t_photo
    Photo.arel_table
  end

  def t_facet
    Facet.arel_table
  end

  private
    def set_default_values
      self.like ||= false
      self.has_comment ||= false
    end

end

  # def mandatory_conditions
  #   photo_rules = [
  #     { :operator => :and, :method => :_start_date },
  #     { :operator => :and, :method => :_end_date   },
  #     { :operator => :and, :method => :_country    },
  #     { :operator => :and, :method => :_city       },
  #     { :operator => :and, :method => :_make       },
  #     { :operator => :or , :method => :_album      },
  #   ]
  #   process_rules(photo_rules)
  # end
  #
  # def conditions
  #   photo_rules = [
  #     { :operator => :and, :method => :_start_date },
  #     { :operator => :and, :method => :_end_date   },
  #     { :operator => :and, :method => :_country    },
  #     { :operator => :and, :method => :_city       },
  #     { :operator => :and, :method => :_make       },
  #     { :operator => :or , :method => :_album      },
  #   ]
  #
  #   facet_rules = [
  #     { :operator => :or , :method => :_has_comment},
  #     { :operator => :or,  :method => :_like       },
  #     { :operator => :or , :method => :_tag},
  #
  #   ]
  #
  #   photo = process_rules(photo_rules)
  #   facet = process_rules(facet_rules)
  #
  #   if !facet
  #       expression = photo
  #   else
  #     expression = photo.or(facet)
  #   end
  #
  #   return expression
  # end
  #
  # def process_rules(rules)
  #   exp = false
  #   rules.each do |rule|
  #     res = send(rule[:method])
  #     if res != nil
  #       if !exp
  #         exp = res
  #       else
  #         if rule[:operator] == :and
  #           exp = exp.and(res)
  #         elsif rule[:operator] == :or
  #           exp = exp.or(res)
  #         end
  #       end
  #     end
  #   end
  #   return exp
  # end




  # def _country
  #   t_location[:country_id].eq(self.country) unless (self.country.blank? || self.country == "-1")
  # end
  #
  # def _city
  #   t_location[:city_id].eq(self.city) unless (self.city.blank? || self.city == "-1")
  # end




  # def _like
  #   t_facet[:type].eq("Like") unless self.like == false
  # end
  #
  # def _has_comment
  #   t_comment[:name].matches("%#{self.has_comment}%").and(t_facet[:type].eq("CommentFacet")) unless self.has_comment == false
  # end
  #
  # def _album
  #   t_facet[:source_id].eq(self.id).and(t_facet[:type].eq("AlbumFacet")) unless self.id.blank?
  # end

  # def join_location
  #   constraint_location = t_location.create_on(t_facet[:source_id].eq(t_location[:id]))
  #   t_photo.create_join(t_location, constraint_location, Arel::Nodes::InnerJoin)
  # end
  #
  # def join_facet
  #   constraint_facet = t_facet.create_on(t_photo[:id].eq(t_facet[:photo_id]))
  #   t_photo.create_join(t_facet, constraint_facet, Arel::Nodes::OuterJoin)
  # end
  #
  # def join_tag
  #   constraint_tag = t_tag.create_on(t_facet[:source_id].eq(t_tag[:id]))
  #   t_facet.create_join(t_tag, constraint_tag, Arel::Nodes::OuterJoin)
  # end
  #
  # def join_comment
  #   constraint_comment = t_comment.create_on(t_facet[:source_id].eq(t_comment[:id]))
  #   t_facet.create_join(t_comment, constraint_comment, Arel::Nodes::OuterJoin)
  # end

  # def join_album_photo
  #   #constraint_album_photo = t_facet.create_on(t_photo[:id].eq(t_facet[:photo_id]))
  #   #t_photo.create_join(t_album_photo, constraint_album_photo, Arel::Nodes::OuterJoin)
  #   # constraint_album_photo = t_album_photo.create_on(t_photo[:id].eq(t_album_photo[:photo_id]))
  #   # t_photo.create_join(t_album_photo, constraint_album_photo, Arel::Nodes::OuterJoin)
  # end
  #
  # # def t_album_photo
  # #   Arel::Table.new("albums_photos")
  # # end

  # def t_location
  #   Location.arel_table
  # end



  # def t_tag
  #   Arel::Table.new("tags")
  # end

  # def t_comment
  #   Arel::Table.new("comments")
  # end
