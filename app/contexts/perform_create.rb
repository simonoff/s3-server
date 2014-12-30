class PerformCreate
  DISPATCHER = Hash.new { |h, k| h[k] = "perform_#{k}" }

  def self.call(params, request)
    PerformCreate.new(params, request).call
  end

  def initialize(params, request)
    @params = params
    @request = request
  end

  def call
    send(DISPATCHER[@params[:s3_action_perform]])
  end

  private

  def perform_s3_multipart_initialization
    s3o = S3Object.find_by(uri: @params[:s3_object_uri]) || S3Object.new
    s3o.uri = @params[:s3_object_uri]
    s3o.bucket = handle_bucket
    s3o.key = @params[:key]
    s3o.content_type = @params[:content_type]
    s3o.save!

    [:ok, :xml, XmlAdapter.s3_multipart_initialization(s3o)]
  end

  def perform_s3_multipart_completion
    dir = File.join('tmp', 'multiparts', "s3o_#{@params['uploadId']}")
    parts = Hash.from_xml(@params[:request_body].read)['CompleteMultipartUpload']['Part']

    # Fetch parts
    parts.each do |part|
      path = File.join(dir, "part_#{part['PartNumber']}.raw")
      File.open(File.join(dir, 'complete.raw'), 'ab') do |final_file|
        final_file << File.read(path)
      end
    end

    s3o = S3Object.find(@params['uploadId'].to_s)
    return :not_found, :xml, XmlAdapter.error_no_such_key(@params[:key]) unless s3o

    s3o.file = File.open(File.join(dir, 'complete.raw'))
    s3o.file.filename = @params[:key].split('/').last
    s3o.size = File.size(s3o.file.path)
    s3o.md5 = Digest::MD5.file(s3o.file.path).hexdigest
    s3o.save!

    # Remove tmp folder
    FileUtils.rm_r(dir)

    [:ok, :xml, XmlAdapter.s3_multipart_completion("#{@request.host}:#{@request.port}", s3o)]
  end

  def perform_upload
    s3o = S3Object.find_by(uri: @params[:s3_object_uri]) || S3Object.new
    s3o.uri = @params[:s3_object_uri]
    s3o.file = @params[:file]
    s3o.bucket = handle_bucket
    s3o.key = @params[:key]
    s3o.content_type = @params[:file].content_type
    s3o.size = File.size(s3o.file.path)
    s3o.md5 = Digest::MD5.file(s3o.file.path).hexdigest
    s3o.save!

    [:created, :xml, XmlAdapter.uploaded_object("#{@request.host}:#{@request.port}", s3o)]
  end

  def handle_bucket
    unless (bucket = Bucket.find_by(name: @params[:bucket]))
      # Create if not exists facilities
      bucket = Bucket.create!(name: @params[:bucket])
    end
    bucket
  end
end
