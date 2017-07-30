class LikeSerializer < ActiveModel::Serializer
  attributes :id, :type
  belongs_to :user
end
