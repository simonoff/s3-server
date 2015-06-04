class S3Manager
  include [S3BasicsV1, S3BasicsV2].sample

  class << self
    def [](client_id)
      @id = client_id
      self
    end

    # return [bucket, key]
    def parse_s3_params(uri)
      elts = uri.split('/')
      [elts.first, elts[1..-1].join('/')]
    end

    def download(output, opts = {})
      @opts = opts

      dl(*S3Client[@id].s3_params, output)
    end

    def upload(file, opts = {})
      @opts = opts

      ul(*S3Client[@id].s3_params, file)
    end

    def object_exists?
      object(*S3Client[@id].s3_params).exists?
    end

    def copy(src_s3_params)
      cp(*src_s3_params) do
        create_object(*S3Client[@id].s3_params)
      end
    end

    def object_size
      object(*S3Client[@id].s3_params).content_length
    end

    def object_size_in_mb
      object_size(*S3Client[@id].s3_params) / 1_048_576
    end

    def delete_object
      object(*S3Client[@id].s3_params).delete
    end
  end
end
