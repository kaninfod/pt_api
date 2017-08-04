class CommentSerializer < ActiveModel::Serializer
  attributes :id, :type, :created, :name, :user

  def user
    UserSerializer.new(object.user).attributes
  end
end
