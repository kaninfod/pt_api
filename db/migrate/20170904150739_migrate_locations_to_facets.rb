class MigrateLocationsToFacets < ActiveRecord::Migration[5.1]
  def change
      say "Found #{Instance.where(rev: nil).count} records to migrate"

      say_with_time "Migrating instances..." do
        user = User.first
        count = 0
        Photo.find_each do |photo|
          LocationFacet.create(
            photo: photo,
            source_id: photo.location_id,
            user: user
          )
          # instance.update(rev: true)
          count += 1
        end
        count
      end
      # fail_count = Instance.where(rev: nil).count
      # fail "Found #{fail_count} not migrated records" unless fail_count == 0
  end
end
