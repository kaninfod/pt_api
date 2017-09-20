class Facet < ApplicationRecord

  belongs_to :photo
  belongs_to :user
  belongs_to :comment,  optional: true, foreign_key: :source_id
  belongs_to :tag,      optional: true, foreign_key: :source_id
  belongs_to :album,    optional: true, foreign_key: :source_id
  belongs_to :location, optional: true, foreign_key: :source_id
  belongs_to :catalog,  optional: true, foreign_key: :source_id
  has_one    :instance, dependent: :destroy


  # def self.album
  #     where(type: 'AlbumFacet')
  # end
end
