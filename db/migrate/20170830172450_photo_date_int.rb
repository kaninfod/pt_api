class PhotoDateInt < ActiveRecord::Migration[5.1]
  def change
    change_column :photos, :photo_date, :bigint

  end
end
