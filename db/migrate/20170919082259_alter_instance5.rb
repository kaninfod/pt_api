class AlterInstance5 < ActiveRecord::Migration[5.1]
  def change
    add_column :instances, :instance_type, :string
  end
end
