class AlterInstances1 < ActiveRecord::Migration[5.1]
  def change
    rename_column :instances, :catalog_facet_id_id, :facet_id
  end
end
