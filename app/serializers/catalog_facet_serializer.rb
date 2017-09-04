class CatalogFacetSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at, :user

  def user
    UserSerializer.new(object.user).attributes
  end
end
