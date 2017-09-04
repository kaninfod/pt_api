class AlbumFacet < Facet
  validates :user_id, uniqueness: { scope: [:photo, :source_id],
    message: "This album exists already" }

  delegate :name, :to => :album
end
