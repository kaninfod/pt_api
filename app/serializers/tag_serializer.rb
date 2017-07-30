class TagSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at, :name
end
