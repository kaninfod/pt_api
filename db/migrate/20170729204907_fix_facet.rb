class FixFacet < ActiveRecord::Migration[5.1]
  def change
    rename_column :facets, :commet, :comment
    remove_column :facets, :like
  end
end
