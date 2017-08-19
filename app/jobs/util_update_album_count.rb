class UtilUpdateAlbumCount < AppJob
  include Resque::Plugins::UniqueJob
  queue_as :utility

  def perform()
    begin
      Album.all.each do |album|
        size = album.album_photos.count
        album.update(size: size)
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
