class BucketFacetSerializer < ActiveModel::Serializer
  attributes :id, :type, :user

  def user
    UserSerializer.new(object.user).attributes
  end
end
