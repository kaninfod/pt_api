class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :date_taken_formatted, :model, :make, :url_tm, :url_md, :url_lg, :url_org, :portrait

  has_many :facets

  def portrait
    object.original_width < object.original_height
    # return true unless object.original_width > object.original_height
  end

end
