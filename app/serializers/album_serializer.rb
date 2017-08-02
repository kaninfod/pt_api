class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :name, :count, :cover_url, :start_date, :end_date, :make, :model, :city , :country
end
