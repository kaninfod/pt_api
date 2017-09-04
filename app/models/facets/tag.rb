class Tag < ActiveRecord::Base
  has_many :facets
  validates :name, uniqueness: true

  has_many :facets, -> { where type: 'TagFacet' }, class_name: 'Facet', foreign_key: :source_id
  has_many :photos, through: :facets, foreign_key: :source_id
end
