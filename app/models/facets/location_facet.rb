class LocationFacet < Facet
  validates :photo_id, uniqueness: { scope: :source_id,
    message: "This album exists already" }

  delegate :address, :to => :album
end
