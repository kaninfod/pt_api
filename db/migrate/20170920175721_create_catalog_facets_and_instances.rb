class CreateCatalogFacetsAndInstances < ActiveRecord::Migration[5.1]
  def change
    say "Found #{Instance.where(rev: nil).count} records to migrate"

    say_with_time "Migrating instances..." do
      # user_id = User.first.id
      # master_id = Catalog.master.id
      count = 0
      Photo.find_each do |photo|
        cf = photo.catalog_facets.first
        i=Instance.create(
          modified: Time.now,
          photo_url: photo.url_org,
          photo_id: photo.id,
          instance_type: "master",
          facet_id: cf.id,
          status: 1,
        )
        i
        count += 1
      end
      count
    end
    fail_count = CatalogFacet.count - Instance.count
    fail "Found #{fail_count} not migrated records" unless fail_count == 0
    
  end
end
