class User < ApplicationRecord
  has_secure_password
  before_save :default_values


  def default_values
    # self.status ||= 'P' # note self.status = 'P' if self.status.nil? might be safer (per @frontendbeauty)
  end

end
