class IndexFacet1 < ActiveRecord::Migration[5.1]
  def change
    # remove_index :facets, [:user_id, :photo_id, :type, :comment]
    # remove_index :facets, name: "index_facets_on_user_id_and_type_and_comment_and_tag_id"
  end
end
