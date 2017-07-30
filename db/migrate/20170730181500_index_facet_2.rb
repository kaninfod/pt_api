class IndexFacet2 < ActiveRecord::Migration[5.1]
  def change
    add_column :facets, :comment_id, :integer
    add_index :facets, [:user_id, :photo_id, :type, :tag_id, :comment_id], unique: true, :name => 'user_photo_type_comment_tag'
    remove_column :facets, :comment
  end
end
