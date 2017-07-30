class FixBucket < ActiveRecord::Migration[5.1]
  def change

    change_table :facets do |t|
      t.belongs_to :photos, foreign_key: true
    end
  end
end
