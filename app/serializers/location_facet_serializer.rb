class LocationFacetSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at, :user, :location

  def location
    LocationSerializer.new(object.location).attributes
  end
  def user
    UserSerializer.new(object.user).attributes
  end
end
