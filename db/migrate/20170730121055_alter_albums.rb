class AlterAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :has_comment, :bool
    remove_column :photos, :path
    remove_column :photos, :filename
    remove_column :photos, :file_thumb_path
  end
end
