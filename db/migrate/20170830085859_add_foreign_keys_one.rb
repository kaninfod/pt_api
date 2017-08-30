class AddForeignKeysOne < ActiveRecord::Migration[5.1]
  def change
    change_column :photos, :location_id, :bigint
    add_foreign_key :photos, :locations
  end
end
