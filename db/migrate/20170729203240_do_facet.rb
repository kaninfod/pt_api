class DoFacet < ActiveRecord::Migration[5.1]
  def change
    add_column :facets, :type, :string
    add_column :facets, :like, :bool
    add_column :facets, :commet, :string
    add_column :facets, :tag_id, :integer

  end
end
