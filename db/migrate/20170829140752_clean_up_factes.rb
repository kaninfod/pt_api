class CleanUpFactes < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :facets, :photos
    remove_index :facets, name: :index_facets_on_photos_id
    remove_column :facets, :photos_id
    remove_foreign_key :facets, :users
    remove_index :facets, name: :index_facets_on_users_id
    remove_column :facets, :users_id
    remove_column :facets, :source_tags_id
  end
end
