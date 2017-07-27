class User < ApplicationRecord
  has_secure_password
  acts_as_voter
  before_save :default_values

  # def avatar_url
  #   "/api/photofiles/#{self.avatar}/photoserve"
  # end

  def default_values
    # self.status ||= 'P' # note self.status = 'P' if self.status.nil? might be safer (per @frontendbeauty)
  end

end
