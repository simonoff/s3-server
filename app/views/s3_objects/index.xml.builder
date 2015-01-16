xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.ListBucketResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |lbr|
  lbr.Name @bucket.name
  lbr.Prefix
  lbr.Marker
  lbr.MaxKeys
  lbr.IsTruncated false
  @s3_objects.each do |s3_object|
    lbr.Contents do |contents|
      contents.Key s3_object.key
      contents.LastModified s3_object.updated_at
      contents.ETag "\"#{s3_object.md5}\""
      contents.Size s3_object.size
      contents.StorageClass 'STANDARD'

      contents.Owner do |owner|
        owner.ID @bucket.user.id
        owner.DisplayName @bucket.user.name
      end
    end
  end
end
