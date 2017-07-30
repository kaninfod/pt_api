class SourceComments1 < ActiveRecord::Migration[5.1]
  def change
    rename_column :facets, :comment_id, :source_comment_id
  end
end
