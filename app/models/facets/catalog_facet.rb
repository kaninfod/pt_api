class CatalogFacet < Facet
  after_create :create_instance

  validates :user_id, uniqueness: { scope: [:photo, :source_id],
    message: "This catalog exists already" }

  delegate :name, :to => :catalog

  def create_instance
    Instance.create(facet: self, status: 0)
  end
end
