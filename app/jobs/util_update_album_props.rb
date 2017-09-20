class UtilUpdateAlbumProps < AppJob
  include Resque::Plugins::UniqueJob
  queue_as :utility

  def perform()
    begin
      Album.all.each do |album|
        size = album.album_photos.count

        if size > 0
          cover_url = album.album_photos.first.url_md
        else
          cover_url = Photo.null_photo
        end

        album.update(size: size, cover_url: cover_url)
      end

      @job_db.update(jobable_id: nil, jobable_type: "Album")
    rescue Exception => e
      @job_db.update(job_error: e, status: 2, completed_at: Time.now)
      Rails.logger.warn "Error raised on job id: #{@job_db.id}. Error: #{e}"
      return
    end
  end

  private

end
