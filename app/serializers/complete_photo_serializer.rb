class CompletePhotoSerializer < ActiveModel::Serializer
  attributes :id, :date_taken_formatted, :model, :make, :url_tm, :url_md, :url_lg, :url_org, :tags
  belongs_to :bucket
  belongs_to :tags
end
