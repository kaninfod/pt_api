class AlterBucket < ActiveRecord::Migration[5.1]
  def change
    rename_table :buckets, :facets
  end
end
