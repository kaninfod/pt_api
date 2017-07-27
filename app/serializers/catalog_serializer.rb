class CatalogSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :cover_url, :sync_from_catalog, :import_mode
end
