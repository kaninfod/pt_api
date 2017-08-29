class Tag < Facet
  belongs_to :photo
  belongs_to :user
  # belongs_to :source_tag, optional: true, class_name: 'SourceTag', foreign_key: :source_id

  delegate :name, :to => :source_tag
  validates :user_id, uniqueness: { scope: [:photo, :source_id],
    message: "This like exists already" }
end
