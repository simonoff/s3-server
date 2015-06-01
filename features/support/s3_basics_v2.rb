module S3BasicsV2
  def self.included(base)
    STDOUT.puts 'Use AWS SDK v2'
    base.extend(ClassMethods)
  end

  module ClassMethods
    def ul(bucket, key, file)
      create_object(bucket, key).upload_file(file)
    end

    def dl(bucket, key, file)
      object(bucket, key).get do |chunk|
        file << chunk
      end
    end

    def cp(bucket, key)
      yield.copy_from(copy_source: "#{bucket}/#{key}")
    end

    def create_bucket(bucket)
      s3.bucket(bucket).create
    end

    def create_object(bucket, key)
      bucket(bucket).object(key)
    end

    def object(bucket, key)
      bucket(bucket).object(key)
    end

    def bucket(bucket)
      s3.bucket(bucket).create unless s3.bucket(bucket).exists?
      s3.bucket(bucket)
    end

    def s3
      ::Aws::S3::Resource.new(
        access_key_id: 'nothing', secret_access_key: 'nothing',
        endpoint: 'http://localhost:10001',
        force_path_style: true, region: 'Shangri_la')
    end
  end
end
