class RemovePhotoDateField < ActiveRecord::Migration[5.1]
  def change
    remove_column :photos, :photo_date
  end
end
