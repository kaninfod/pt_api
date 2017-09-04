class AddIndexFacet < ActiveRecord::Migration[5.1]
  def change
    add_index :facets, :type
  end
end
