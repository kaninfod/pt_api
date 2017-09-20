class DeleteDropboxPhotoFromCatalog < AppJob
  queue_as :utility

  def perform(photo_id, access_token)
    begin
      response = delete_photo(photo_id, access_token)
      @job_db.update(jobable_id: photo_id, jobable_type: "Photo")
      return response
    rescue Exception => e
      @job_db.update(job_error: e, status: 2, completed_at: Time.now)
      Rails.logger.warn "Error raised on job id: #{@job_db.id}. Error: #{e}"
      return
    end

  end
end



def delete_photo(path, access_token)

  uri = URI("https://api.dropboxapi.com/2/files/delete_v2")
  remote_file_path = "/#{remote_file_path}" #{}"/Apps/Phototank/#{remote_file_path}"

  params = { :path => path }

  req = Net::HTTP::Post.new(uri.request_uri)
  req['Authorization'] = "Bearer #{access_token}"
  req['Content-Type'] = "application/json"
  req.body = params.to_json

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {
    |http| http.request(req)
  }

  if res.is_a?(Net::HTTPSuccess)
    return JSON.parse(res.body)
  end

end
