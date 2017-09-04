class CatalogFacet < Facet
  validates :user_id, uniqueness: { scope: [:photo, :source_id],
    message: "This catalog exists already" }

  delegate :name, :to => :catalog
end
