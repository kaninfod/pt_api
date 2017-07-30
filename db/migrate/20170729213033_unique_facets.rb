class UniqueFacets < ActiveRecord::Migration[5.1]
  def change
    rename_column :facets, :user, :user_id
    add_index :facets, [:user_id, :type, :comment, :tag_id], unique: true
  end
end
