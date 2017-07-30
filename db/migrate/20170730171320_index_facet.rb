class IndexFacet < ActiveRecord::Migration[5.1]
  def change
    add_index :facets, [:user_id, :photo_id, :type, :comment], unique: true
  end
end
