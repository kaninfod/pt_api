class CleanUpFactesSomeMoreEvenMore < ActiveRecord::Migration[5.1]
  def change
    drop_table :votes
    rename_column :facets, :source_tag_id, :source_tag_id
    add_index :facets, :photo_id
    add_index :facets, :source_tag_id
  end
end
