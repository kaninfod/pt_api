class TagTableAlter < ActiveRecord::Migration[5.1]
  def change
    # rename_table :tags, :source_tags
    remove_foreign_key :facets, :photos
    remove_column :facets, :photos_id
  end
end
