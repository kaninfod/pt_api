class TagSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at, :name, :user

  def user
    UserSerializer.new(object.user).attributes
  end
end
