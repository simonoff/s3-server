class S3Manager
  include S3Basicis

  class << self
    # return [bucket, key]
    def parse_s3_params(uri)
      elts = uri.split('/')
      [elts.first, elts[1..-1].join('/')]
    end

    def download(output, opts = {})
      @opts = opts

      object(*S3Client.s3_params).read do |chunk|
        output << chunk
      end
    end

    def upload(file, opts = {})
      @opts = opts

      create_object(*S3Client.s3_params).write(file: file.path)
    end

    # /!\ Does not work !
    def upload_multipart(file, opts = {})
      @opts = opts

      create_object(*S3Client.s3_params).write(content_length: file.size) do |buffer, bytes|
        buffer.write(file.read(bytes))
      end
    end

    def object_exists?
      object(*S3Client.s3_params).exists?
    end

    def copy(src_s3_params)
      object(*src_s3_params).copy_to(create_object(*S3Client.s3_params))
    end

    def copy_from_object(s3_object, dst_bucket, dst_key)
      s3_object.copy_to(create_object(dst_bucket, dst_key))
    end

    def object_size
      object(*S3Client.s3_params).content_length
    end

    def object_size_in_mb
      object_size(*S3Client.s3_params) / 1_048_576
    end
  end
end
