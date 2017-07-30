class FixTagFacet1 < ActiveRecord::Migration[5.1]
  def change
    rename_column :facets, :tag_id, :source_tag_id
  end
end
