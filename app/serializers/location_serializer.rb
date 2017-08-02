class LocationSerializer < ActiveModel::Serializer
  attributes :id, :address, :country_name, :city_name, :map_url
end
