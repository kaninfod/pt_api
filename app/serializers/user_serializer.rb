class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :avatar, :remember_token
end
