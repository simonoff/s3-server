module RequestNormalizer
  class << self
    def normalize_create(params)
      # Change stored filename
      fname = params['key'].split('/').last
      params['file'].original_filename = fname
    end

    def normalize_index(params, request)
      path = request.path
      query = request.query_parameters
      elts = path.split('/')

      case
      when path == '/'
        params['s3_action_perform'] = :list_buckets
      when elts.length < 3
        params['s3_action_perform'] = :ls_bucket
        params['ls_bucket_query'] = query
      when query.key?('acl')
        params['s3_action_perform'] = :get_acl
      else
        params['s3_action_perform'] = :get_object
      end
    end
  end
end
