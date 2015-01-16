xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.ListBucketResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |lbr|
  lbr.Name @bucket.name
  lbr.Prefix
  lbr.Marker
  lbr.MaxKeys 1000
  lbr.IsTruncated false
end
