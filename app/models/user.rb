class User < ApplicationRecord
  has_secure_password

  scope :admin, -> { where(email: 'admin@mail.com').first }
end
