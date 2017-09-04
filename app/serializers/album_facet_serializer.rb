class AlbumFacetSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at, :name, :user, :album

  def album
    AlbumSerializer.new(object.album).attributes
  end

  def user
    UserSerializer.new(object.user).attributes
  end
end
