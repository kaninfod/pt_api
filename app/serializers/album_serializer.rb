class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :name, :count, :cover_url
end
