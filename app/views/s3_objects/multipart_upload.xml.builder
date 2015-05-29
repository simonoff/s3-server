xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.PostResponse(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |pr|
  pr.Location "http://#{request.host}:#{request.port}" \
              "/#{@bucket.name}/#{@s3_object.key}"
  pr.Bucket @bucket.name
  pr.Key @s3_object.key
  pr.ETag @s3_object.md5
  pr.UploadId @s3_object.id
end
