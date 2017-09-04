class LikeFacet < Facet
  validates :user_id, uniqueness: { scope: :photo,
    message: "This like exists already" }
end
