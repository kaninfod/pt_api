class AlterAlbumsTable < ActiveRecord::Migration[5.1]
  def change
    rename_column :albums, :end, :end_date
    rename_column :albums, :start, :start_date
    remove_column :albums, :photo_ids
  end
end
