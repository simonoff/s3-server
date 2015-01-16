xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.ListAllMyBucketsResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |lam|
  lam.Owner do |owner|
    owner.ID @user.id
    owner.DisplayName @user.name
  end
  lam.Buckets do |buckets|
    @buckets.each do |bucket|
      buckets.Bucket do |b|
        b.Name bucket.name
        b.CreationDate bucket.created_at
      end
    end
  end
end
