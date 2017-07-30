class FacetSerializer < ActiveModel::Serializer
  attributes :id, :user
  belongs_to :photo
  # belongs_to :comment
  # belongs_to :tag
  belongs_to :user
end
