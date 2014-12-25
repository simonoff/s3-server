module RequestNormalizer
  class << self
    def normalize_create(params, request)
      params[:s3_object_uri] = "#{params[:path]}/#{params[:key]}"
      normalize_file_upload(params, request)
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
        params[:ls_bucket_query] = query
      when query.key?('acl')
        params[:s3_action_perform] = :get_acl
      else
        params[:s3_action_perform] = :get_object
        params[:s3_object_uri] = "#{params[:path]}.#{params[:format]}"
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
        params[:s3_object_uri] = "#{params[:path]}.#{params[:format]}"
        params[:bucket] = elts[1]
        params[:key] = path.split('/')[2..-1].join('/')
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
        params[:s3_object_uri] = "#{params[:path]}.#{params[:format]}"
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
      return unless copy_source.nil? || copy_source.size != 1
      src_elts = copy_source.first.split('/')
      root_offset = src_elts.firts.empty? ? 1 : 0

      params[:src_bucket] = src_elts[root_offset]
      params[:src_object] = src_elts[1 + root_offset, -1].join('/')
      params[:s3_action_perform] = :copy_object
    end
  end
end
