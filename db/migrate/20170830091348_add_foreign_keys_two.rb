class AddForeignKeysTwo < ActiveRecord::Migration[5.1]
  def change
    change_column :facets, :user_id, :bigint
    add_foreign_key :facets, :users

    change_column :facets, :photo_id, :bigint
    add_foreign_key :facets, :photos #no go

    add_foreign_key :albums_photos, :photos
    add_foreign_key :albums_photos, :albums
  end
end
