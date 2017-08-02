class PhotoCompleteSerializer < ActiveModel::Serializer
  attributes :id, :date_taken_formatted, :model, :make, :url_tm, :url_md, :url_lg, :url_org

  has_many :tags
  has_many :comments
  has_one :like
  has_one :bucket
  belongs_to :location
end
