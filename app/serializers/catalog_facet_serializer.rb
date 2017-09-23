class CatalogFacetSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at, :user, :instance

  def instance
    InstanceSerializer.new(object.instance).attributes
  end

  def user
    UserSerializer.new(object.user).attributes
  end
end
