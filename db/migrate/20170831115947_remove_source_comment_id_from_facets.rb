class RemoveSourceCommentIdFromFacets < ActiveRecord::Migration[5.1]
  def change
    remove_column :facets, :source_comment_id
  end
end
