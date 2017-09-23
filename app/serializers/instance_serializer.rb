class InstanceSerializer < ActiveModel::Serializer
  attributes :id, :instance_type, :photo_url, :photo_id, :status, :modified

end
