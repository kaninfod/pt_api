require 'flickraw'
class DeleteFlickrPhotoFromCatalog < AppJob
  queue_as :utility

  def perform(photo_id, flickr_keys)
    begin
      response = delete_photo(photo_id, flickr_keys)
      @job_db.update(jobable_id: photo_id, jobable_type: "Photo")
      return response
    rescue Exception => e
      @job_db.update(job_error: e, status: 2, completed_at: Time.now)
      Rails.logger.warn "Error raised on job id: #{@job_db.id}. Error: #{e}"
      return
    end

  end
end

def delete_photo(path, flickr_keys)
  FlickRaw.api_key = flickr_keys[:appkey]
  FlickRaw.shared_secret= flickr_keys[:appsecret]
  flickr.access_token = flickr_keys[:access_token]
  flickr.access_secret = flickr_keys[:oauth_token_secret]
  return flickr.photos.delete :photo_id=>path
end
