class PhotoSimpleSerializer < ActiveModel::Serializer
  attributes :id, :date_taken_formatted, :url_tm, :url_md, :url_lg, :url_org
  has_many :facets
end
