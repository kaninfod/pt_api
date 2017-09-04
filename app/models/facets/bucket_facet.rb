class BucketFacet < Facet
  validates :user_id, uniqueness: { scope: :photo,
    message: "This bucket exists already" }
end
