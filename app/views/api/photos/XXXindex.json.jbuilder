json.photos @photos do |photo|
  json.id           photo.id
  json.date_taken   photo.date_taken_formatted
  json.url          photo.url('tm')
  json.url_org      photo.url('org')
  json.url_lg       photo.url('lg')
  json.bucket       @bucket_ids.include? photo.id
end
