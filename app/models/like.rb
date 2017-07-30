class Like < Facet
  belongs_to :photo
  belongs_to :user
  validates :user_id, uniqueness: { scope: :photo,
    message: "This like exists already" }
end
