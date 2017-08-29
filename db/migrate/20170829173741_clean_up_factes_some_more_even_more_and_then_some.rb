class CleanUpFactesSomeMoreEvenMoreAndThenSome < ActiveRecord::Migration[5.1]
  def change
    rename_column :facets, :source_tag_id, :source_id
  end
end
