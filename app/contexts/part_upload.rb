class PartUpload
  def self.call(s3_object, part_number, req_body)
    PartUpload.new(s3_object, part_number, req_body).call
  end

  def initialize(s3_object, part_number, req_body)
    @s3_object, @part_number, @req_body = s3_object, part_number, req_body
  end

  def call
    dir = File.join('tmp', 'multiparts', "s3o_#{@s3_object.id}")
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    path = File.join(dir, "part_#{@part_number}.raw")
    File.open(path, 'wb') do |part|
      part << @req_body
    end

    @s3_object.assign_attributes(md5: Digest::MD5.file(path).hexdigest)
  end
end
