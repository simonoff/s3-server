module S3Basicis
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def create_bucket(bucket)
      s3.buckets.create(bucket)
    end

    def create_object(bucket, key)
      create_bucket(bucket) unless s3.buckets[bucket].exists?
      s3.buckets[bucket].objects[key]
    end

    def object(bucket, key)
      s3.buckets["#{bucket}"].objects["#{key}"]
    end

    def bucket(bucket)
      s3.buckets["#{bucket}"]
    end

    def s3
      ::AWS::S3.new({
        access_key_id: '', secret_access_key: '',
        s3_endpoint: 'localhost:10001',
        s3_force_path_style: true, use_ssl: false })
    end
  end
end
