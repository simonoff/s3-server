module RequestNormalizer
  class << self
    def normalize_create(params, request)
      path = request.path
      query = request.query_parameters
      elts = path.split('/')

      params[:bucket] = parse_bucket_name(params)
      params[:s3_object_uri] = rebuild_uri(params)
      case
      when elts.length > 3 && query.key?('uploads')
        params[:s3_action_perform] = :upload_initialization
      else
        params[:s3_action_perform] = :upload
        normalize_file_upload(params, request)
      end
    end

    def normalize_index(params, request)
      path = request.path
      query = request.query_parameters
      elts = path.split('/')

      case
      when path == '/'
        params[:s3_action_perform] = :list_buckets
      when elts.length < 3
        params[:s3_action_perform] = :ls_bucket
        params[:bucket] = parse_bucket_name(params)
        params[:ls_bucket_query] = query
      when query.key?('acl')
        params[:s3_action_perform] = :get_acl
      else
        params[:s3_action_perform] = :get_object
        params[:bucket] = parse_bucket_name(params)
        params[:s3_object_uri] = rebuild_uri(params)
        params[:request_method] = request.method
      end
    end

    def normalize_update(params, request)
      path = request.path
      query = request.query_parameters
      elts = path.split('/')

      case
      when path == '/'
        fail UnsupportedOperation
      when elts.length < 3
        params[:s3_action_perform] = :create_bucket
      when query.key?('acl')
        params[:s3_action_perform] = :set_acl
      else
        params[:s3_action_perform] = :store_object
        params[:s3_object_uri] = rebuild_uri(params)
        params[:bucket] = parse_bucket_name(params)
        params[:key] = parse_key_name(params)
        normalize_file_upload(params, request)
      end

      normalize_copy_source(params, request.headers['x-amz-copy-source'])
    end

    def normalize_destroy(params, request)
      path = request.path
      query = request.query_parameters
      elts = path.split('/')

      case
      when path == '/'
        fail UnsupportedOperation
      when elts.length < 3
        params[:s3_action_perform] = :rm_bucket
        params[:rm_bucket_query] = query
      else
        params[:s3_action_perform] = :rm_object
        params[:s3_object_uri] = rebuild_uri(params)
      end
    end

    private

    def normalize_file_upload(params, request)
      if params[:file]
        normalize_multipart_upload(params)
      else
        normalize_singlepart_upload(params, request)
      end
    end

    def normalize_singlepart_upload(params, request)
      fname = params[:key].split('/').last
      tmp_file = Tempfile.new(fname)
      tmp_file.binmode
      tmp_file.write(request.body.read)

      params[:file] = ActionDispatch::Http::UploadedFile.new(
        tempfile: tmp_file,
        filename: fname,
        type: request.content_type || 'application/octet-stream',
        headers: "Content-Disposition: form-data; name=\"file\"; filename=\"noname.txt\"\r\n" \
                 "Content-Type: #{request.content_type || 'application/octet-stream'}\r\n"
      )
    end

    def normalize_multipart_upload(params)
      # Change stored filename
      fname = params[:key].split('/').last
      params[:file].original_filename = fname
    end

    def normalize_copy_source(params, copy_source)
      return if copy_source.nil? || copy_source.size != 1
      src_elts = copy_source.first.split('/')
      root_offset = src_elts.firts.empty? ? 1 : 0

      params[:src_bucket] = src_elts[root_offset]
      params[:src_object] = src_elts[1 + root_offset, -1].join('/')
      params[:s3_action_perform] = :copy_object
    end

    def parse_bucket_name(params)
      params[:path].split('/').first
    end

    def parse_key_name(params)
      rebuild_uri(params).split('/')[1..-1].join('/')
    end

    def rebuild_uri(params)
      case
      when params[:format]
        params[:s3_object_uri] = "#{params[:path]}/#{params[:format]}"
      when params[:key]
        params[:s3_object_uri] = "#{params[:path]}/#{params[:key]}"
      end
    end
  end
end
