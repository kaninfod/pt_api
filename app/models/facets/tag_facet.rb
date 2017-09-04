class TagFacet < Facet

  delegate :name, :to => :tag
  validates :user_id, uniqueness: { scope: [:photo, :source_id],
    message: "This tag exists already" }
end
