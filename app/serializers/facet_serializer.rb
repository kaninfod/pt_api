class FacetSerializer < ActiveModel::Serializer
  attributes :id, :user
  belongs_to :photo
  belongs_to :tag_facets
  # belongs_to :comments
  # belongs_to :like
  # belongs_to :tags
  # belongs_to :comment
  # belongs_to :tag
  belongs_to :user
end
