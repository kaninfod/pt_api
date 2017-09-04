class RenameSourceComment < ActiveRecord::Migration[5.1]
  def change
    rename_table :source_comments, :comments
    rename_table :source_tags, :tags
  end
end
