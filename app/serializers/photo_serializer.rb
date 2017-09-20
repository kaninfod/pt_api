class PhotoSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  has_many :facets#, :serializer => FacetSerializer
  attributes :id, :date_taken_formatted, :model, :make, :url_tm, :url_md, :url_lg, :url_org, :portrait, :status
  attribute :links do
      id = object.id
      {
        self: api_photo_path(id),
        location: api_location_path(object.location_facet.id),
      }
    end

  def portrait
    object.original_width < object.original_height
  end

end
