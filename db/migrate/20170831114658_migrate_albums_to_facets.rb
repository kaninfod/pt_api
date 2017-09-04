class MigrateAlbumsToFacets < ActiveRecord::Migration[5.1]
  def change
    user = User.first
    count = 0
    Album.find_each do |album|
      album.photos.find_each do |photo|
        AlbumFacet.create(
          photo: photo,
          album: album,
          user: user
        )
      end
      count += 1
    end
    count
  end
end
