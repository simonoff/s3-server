class CopyObject
  def self.call(source, uri, filename, bucket, key)
    CopyObject.new(source, uri, filename, bucket, key).call
  end

  def initialize(source, uri, filename, bucket, key)
    @source, @uri, @filename, @bucket, @key = source, uri, filename, bucket, key
  end

  def call
    @s3_object = S3Object.find_by(uri: @uri) || S3Object.new(uri: @uri, bucket: @bucket, key: @key)
    @s3_object.update_attributes(file: File.open(@source.file.path))
    @s3_object.update_attributes(
        content_type: @source.content_type, size: File.size(@s3_object.file.path),
        md5: Digest::MD5.file(@s3_object.file.path).hexdigest)
    @s3_object
  end
end
