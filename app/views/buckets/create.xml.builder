xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.CreateBucketResponse(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |cbr1|
  cbr1.CreateBucketResponse do |cbr2|
    cbr2.Bucket @bucket.name
  end
end
