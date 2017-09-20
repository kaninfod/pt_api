class AddCoverurlColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :cover_url, :string
  end
end
