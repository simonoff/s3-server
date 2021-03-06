class PartUpload
  def self.call(upload_id, part_number, req_body)
    PartUpload.new(upload_id, part_number, req_body).call
  end

  def initialize(upload_id, part_number, req_body)
    @upload_id, @part_number, @req_body = upload_id, part_number, req_body
  end

  def call
    dir = File.join('tmp', 'multiparts', "s3o_#{@upload_id}")
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    path = File.join(dir, "part_#{@part_number}.raw")
    File.open(path, 'wb') do |part|
      part << @req_body
    end

    Digest::MD5.file(path).hexdigest
  end
end
