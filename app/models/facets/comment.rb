class Comment < ActiveRecord::Base
  has_many :facets, -> { where type: 'CommentFacet' }, class_name: 'Facet', foreign_key: :source_id
  has_many :photos, through: :facets, foreign_key: :source_id

  validates :name, uniqueness: true
end
