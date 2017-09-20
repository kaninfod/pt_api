class AlterInstances < ActiveRecord::Migration[5.1]
  def change
    add_reference :instances, :catalog_facet_id, index: true #might be BS
    change_column :facets, :source_id, :bigint
    # add_foreign_key :facets, :instances, column: :source_id
  end
end
