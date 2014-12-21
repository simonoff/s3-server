module BucketQuery
  # http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html
  #
  # Only prefix & max-keys are supported
  def matches(query)
    case
    when query['prefix']
      s3_objects.where('key LIKE?', "%#{query['prefix']}%")
        .first(query['max-keys'])
    else
      s3_objects.first(query['max-keys'])
    end
  end
end
