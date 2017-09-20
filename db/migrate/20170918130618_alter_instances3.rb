class AlterInstances3 < ActiveRecord::Migration[5.1]
  def change
    add_column :instances, :remote_url, :string
    add_column :instances, :remote_id, :string
    remove_index :instances , [:photo_id, :catalog_id]
    remove_column :instances , :photo_id
    remove_column :instances , :catalog_id
  end
end
