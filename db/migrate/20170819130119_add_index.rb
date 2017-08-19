class AddIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :photos, :date_taken
    add_index :photos, :status
    add_index :photos, :phash

    add_column :albums, :size, :integer

  end
end
