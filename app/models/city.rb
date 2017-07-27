class City < ActiveRecord::Base
  has_many :locations, dependent: :destroy
  validates :name , uniqueness: true
end
