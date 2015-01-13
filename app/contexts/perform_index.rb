class PerformIndex
  DISPATCHER = Hash.new { |h, k| h[k] = "perform_#{k}" }

  def self.call(params)
    PerformIndex.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    send(DISPATCHER[@params[:s3_action_perform]])
  end

  private

  def perform_list_buckets
    buckets = Bucket.all
    [:ok, :xml, XmlAdapter.buckets(buckets)]
  end

  def perform_ls_bucket
    bucket = Bucket.find_by(name: @params[:path])
    return :not_found, :xml, XmlAdapter.error_no_such_bucket(@params[:path]) unless bucket

    normalize_ls_bucket_query
    [:ok, :xml, XmlAdapter.bucket_query(bucket, @params[:ls_bucket_query])]
  end

  def perform_get_acl
    [:ok, :xml, XmlAdapter.acl]
  end

  def perform_get_object
    s3o = S3Object.find_by(uri: @params[:s3_object_uri])

    unless s3o && File.exist?(s3o.file.path)
      return :not_found, :xml, XmlAdapter.error_no_such_key(@params[:key])
    end

    case @params[:request_method]
    when 'HEAD'
      [:ok, :head, s3o]
    when 'GET'
      [:ok, :file, s3o]
    else
      fail UnsupportedOperation
    end
  end

  def normalize_ls_bucket_query
    @params[:ls_bucket_query].tap do |query|
      query['max-keys'] = (query['max-keys'] || 1000).to_i
      query['prefix'] = query['prefix'].to_s if query['prefix']
      query['marker'] = query['prefix'].to_s if query['prefix']
    end
  end
end
