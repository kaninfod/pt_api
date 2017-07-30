class Tag < Facet
  belongs_to :photo
  belongs_to :user
  belongs_to :source_tag, default: -> {SourceTag.first}

  delegate :name, :to => :source_tag
  validates :user_id, uniqueness: { scope: [:photo, :source_tag_id],
    message: "This like exists already" }
end
