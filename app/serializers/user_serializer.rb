class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :avatar, :token
end
