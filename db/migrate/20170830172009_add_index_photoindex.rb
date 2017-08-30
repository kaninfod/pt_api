class AddIndexPhotoindex < ActiveRecord::Migration[5.1]
  def change
    add_index :photos, :photo_date
  end
end
