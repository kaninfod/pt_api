class AlterInstance4 < ActiveRecord::Migration[5.1]
  def change
    rename_column :instances, :remote_url, :photo_url
    rename_column :instances, :remote_id, :photo_id
  end
end
