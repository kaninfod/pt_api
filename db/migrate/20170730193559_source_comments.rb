class SourceComments < ActiveRecord::Migration[5.1]
  def change
    create_table :source_comments do |t|
      t.string :name, :limit => 255
    end
  end
end
