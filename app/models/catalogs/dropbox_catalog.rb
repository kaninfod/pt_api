require 'dropbox_sdk'
class DropboxCatalog < Catalog
  # before_destroy :delete_contents
  serialize :ext_store_data, Hash
  include DropboxServices

  def oauth_init
    self.appkey = Rails.configuration.dropbox["appkey"]
    self.appsecret = Rails.configuration.dropbox["appsecret"]

    redirect_base_url = Rails.configuration.phototank["api_base_url"] #self.redirect_uri
    redirect_url_ext = "/api/catalogs/oauth_callback"

    authorize_url = "https://www.dropbox.com/oauth2/authorize"
    client_id = "client_id=#{self.appkey}"
    response_type = "response_type=code"
    self.redirect_uri = "redirect_uri=#{redirect_base_url}#{redirect_url_ext}"
    state = self.id

    self.auth_url = "#{authorize_url}?#{client_id}&#{response_type}&#{self.redirect_uri}&state=#{state}"
    self.save
    return self
  end

  def oauth_callback(code)
    response = dropbox_get_token(code)
    self.update(
      access_token: response["access_token"],
      verifier: code,
      dropbox_user_id: response["uid"]
    )
    LocalCloneInstancesFromCatalogJob.perform_later self.id, self.sync_from_catalog
  end

  def import(use_resque=true)
    raise "Catalog is not online" unless online
    if not self.sync_from_catalog.blank?
        LocalCloneInstancesFromCatalogJob.perform_later self.id, self.sync_from_catalog
    end
  end

  def import_photo(photo_id)

    photo = Photo.find(photo_id)
    instance = photo.catalog_facets.find_by(catalog: self).instance
    photofile = Photofile.find(photo.org_id)
    photofile_split = photofile.path.split(File::SEPARATOR)

    dropbox_path = File.join(self.name, photofile_split[-4], photofile_split[-3], photofile_split[-2])
    dropbox_file = File.join(dropbox_path, photofile_split[-1]  )

    if instance.status != 1

      begin
        src = photofile.path

        response = upload(src, dropbox_file)

        _remote_url = response["path_lower"].split('/')
        _filename = _remote_url.pop
        _remote_url = File.join(_remote_url)
        _base_url = "https://www.dropbox.com/home/Apps/Phototank"
        _remote_url = "#{_base_url}#{_remote_url}?preview=#{_filename}"

        instance.update(
          instance_type: "dropbox",
          photo_url: _remote_url,
          photo_id: response["path_lower"],
          size: response["bytes"],
          rev: response["rev"],
          modified: response["server_modified"].to_datetime,
          status: 1
        )

      end
    else
      raise "File exists in Dropbox with same revision id and path"
    end
  end

  def online
    true if access_token
  end

  def delete_photo(photo_id)
    begin
      if not photo_id.nil?
        self.client.file_delete photo_id
      end
    rescue Exception => e
      logger.debug "#{e}"
    end
  end

  def auth_url=(new_auth_url)
    self.ext_store_data = self.ext_store_data.merge({:auth_url => new_auth_url})
  end

  def auth_url
    self.ext_store_data[:auth_url]
  end

  def appkey=(new_appkey)
    self.ext_store_data = self.ext_store_data.merge({:appkey => new_appkey})
  end

  def appkey
    self.ext_store_data[:appkey]
  end

  def appsecret=(new_appsecret)
    self.ext_store_data = self.ext_store_data.merge({:appsecret => new_appsecret})
  end

  def appsecret
    self.ext_store_data[:appsecret]
  end

  def redirect_uri=(new_redirect_uri)
    self.ext_store_data = self.ext_store_data.merge({:redirect_uri => new_redirect_uri})
  end

  def redirect_uri
    self.ext_store_data[:redirect_uri]
  end

  def verifier=(new_verifier)
    self.ext_store_data = self.ext_store_data.merge({:verifier => new_verifier})
  end

  def verifier
    self.ext_store_data[:verifier]
  end

  def access_token=(new_access_token)
    self.ext_store_data = self.ext_store_data.merge({:access_token => new_access_token})
  end

  def access_token
    self.ext_store_data[:access_token]
  end

  def dropbox_user_id=(new_user_id)
    self.ext_store_data = self.ext_store_data.merge({:dropbox_user_id => new_user_id})
  end

  def dropbox_user_id
    self.ext_store_data[:dropbox_user_id]
  end

  def client
    if not defined?(@client)
      @client = DropboxClient.new(self.access_token)
    end
    @client
  end

  def account_info
    self.client.account_info
  end

  def metadata(path)
    begin
      self.client.metadata(path)
    rescue
    end
  end

  def add_file(local_path, dropbox_path)
    self.client.put_file(dropbox_path, open(local_path), overwrite=true)
  end

  def add_file_in_chunks(dropbox_path, local_path)

    local_file_path = local_path
    dropbox_target_path = dropbox_path
    chunk_size = 4*1024*1024
    local_file_size = File.size(local_file_path)
    uploader = self.client.get_chunked_uploader(File.new(local_file_path, "r"), local_file_size)
    retries = 0
    puts "Uploading..."

    while uploader.offset < uploader.total_size
      begin
        uploader.upload(chunk_size)
      rescue DropboxError => e
        if retries > 10
          puts "- Error uploading, giving up."
          break
        end
        puts "- Error uploading, trying again..."
        retries += 1
      end
    end
    puts "Finishing upload..."
    uploader.finish(dropbox_target_path)

    puts "Done."
  end

  def create_folder(path)
    begin
      self.client.file_create_folder(path)
    rescue DropboxError => e
      self.metadata(path)
    end
  end

  def exists(path)
    response = self.metadata(path)
    if not response.nil?
      if Instance.where(rev: response["rev"]).present?
        return true
      else
        return false
      end
    end
    return false
  end

end


# def auth
#
#   self.appkey = Rails.configuration.dropbox["appkey"]
#   self.appsecret = Rails.configuration.dropbox["appsecret"]
#   base_url = self.redirect_uri
#   url_ext = "/catalogs/authorize_callback"
#   self.redirect_uri = "#{base_url}#{url_ext}"
#   flow = DropboxOAuth2FlowNoRedirect.new(self.appkey, self.appsecret)
#   self.auth_url = flow.start()
#   self.save
# end
#
# def callback
#   begin
#     flow = DropboxOAuth2FlowNoRedirect.new(self.appkey, self.appsecret)
#     access_token, dropbox_user_id = flow.finish(self.verifier)
#
#     self.access_token = access_token
#     self.dropbox_user_id = dropbox_user_id
#
#     self.save
#     return true unless self.access_token.blank?
#     return false
#   rescue Exception => e
#     return false
#   end
# end
