xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.InitiateMultipartUploadResult(
  xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |imur|
    imur.Bucket @bucket.name
    imur.Key @s3_object.key
    imur.UploadId @s3_object.id.to_s
  end
