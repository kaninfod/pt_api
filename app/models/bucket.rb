class Bucket < Facet
  belongs_to :photo
  belongs_to :user
  validates :user_id, uniqueness: { scope: :photo,
    message: "This bucket exists already" }
end
