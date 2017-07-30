class CommentSerializer < ActiveModel::Serializer
  attributes :id, :type, :created, :name
end
