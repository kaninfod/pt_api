class SourceTag < ActiveRecord::Base
  has_many :tags
  validates :name, uniqueness: true
end
