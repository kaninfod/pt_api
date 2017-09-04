class BucketFacetSerializer < ActiveModel::Serializer
  attributes :id, :photo_id, :type, :user

  def user
    UserSerializer.new(object.user).attributes
  end
end
