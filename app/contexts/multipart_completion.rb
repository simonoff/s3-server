class MultipartCompletion
  def self.call(s3_object, req_body)
    MultipartCompletion.new(s3_object, req_body).call
  end

  def initialize(s3_object, req_body)
    @s3_object = s3_object
    @req_body = req_body
  end

  def call
    dir = File.join('tmp', 'multiparts', "s3o_#{@s3_object.id}")
    return unless File.directory?(dir) # Prevent to multiple completion calls (FIX: it is not in AWS API specs)
    parts = Hash.from_xml(@req_body)['CompleteMultipartUpload']['Part']

    # Fetch parts
    parts.each do |part|
      path = File.join(dir, "part_#{part['PartNumber']}.raw")
      File.open(File.join(dir, 'complete.raw'), 'ab') do |final_file|
        final_file << File.read(path)
      end
    end

    file = File.open(File.join(dir, 'complete.raw'))
    @s3_object.assign_attributes(file: file, size: File.size(file.path),
                                 md5: Digest::MD5.file(file.path).hexdigest)

    FileUtils.rm_r(dir)
  end
end
