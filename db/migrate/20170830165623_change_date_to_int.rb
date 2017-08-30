class ChangeDateToInt < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :photo_date, :timestamp, null: false, index: true
  end
end
