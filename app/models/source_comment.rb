class SourceComment < ActiveRecord::Base
  has_many :comments
  validates :name, uniqueness: true
end
