class CommentSerializer < ActiveModel::Serializer
  attributes :id, :type, :created, :user

  def user
    UserSerializer.new(object.user).attributes
  end
end
