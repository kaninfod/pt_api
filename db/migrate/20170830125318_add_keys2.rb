class AddKeys2 < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :facets, :photos
  end
end
