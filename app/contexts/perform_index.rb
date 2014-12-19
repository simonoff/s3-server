class PerformIndex
  DISPATCHER = Hash.new { |h, k| h[k] = "perform_#{k}" }

  def self.call(params)
    PerformIndex.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    send(DISPATCHER[@params['s3_action_perform']])
  end

  private

  def perform_list_buckets
    #TODO
  end

  def perform_ls_bucket
    bucket = Bucket.find_by(name: @params['path'])
    return 404, :xml, XmlAdapter.error_no_such_bucket(@params['path']) unless bucket

    normalize_ls_bucket_query
    [200, :xml, XmlAdapter.bucket_query(bucket, @params['ls_bucket_query'])]
  end

  def perform_get_acl
    #TODO
  end

  def perform_get_object
    #TODO
  end

  def normalize_ls_bucket_query
    @params['ls_bucket_query'].tap do |query|
      query['max-keys'] = (query['max-keys'] || 1000).to_i
      query['prefix'] = query['prefix'].to_s if query['prefix']
      query['marker'] = query['prefix'].to_s if query['prefix']
    end
  end
end
