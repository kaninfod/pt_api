class PhotoSimpleSerializer < ActiveModel::Serializer
  attributes :id, :date_taken_formatted, :url_tm, :url_md, :url_lg, :url_org, :status
  has_many :tags
  has_many :comments
  has_one :like
  has_one :bucket
  # has_many :facets
end
