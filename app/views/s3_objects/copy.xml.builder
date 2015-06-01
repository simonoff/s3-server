xml.CopyObjectResult do |result|
  result.LastModified @s3_object.updated_at
  result.ETag "\"#{@s3_object.md5}\""
end
