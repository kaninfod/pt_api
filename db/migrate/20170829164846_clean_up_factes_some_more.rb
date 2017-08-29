class CleanUpFactesSomeMore < ActiveRecord::Migration[5.1]
  def change
    drop_table :comments
    drop_table :taggings
    remove_index :facets, name: :user_photo_type_comment_tag
  end
end
