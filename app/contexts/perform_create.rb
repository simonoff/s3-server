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

  def perform_upload_initialization
    s3o = S3Object.find_by(uri: @params[:s3_object_uri]) || S3Object.new
    s3o.uri = @params[:s3_object_uri]
    s3o.bucket = handle_bucket
    s3o.key = @params[:key]
    s3o.md5 = '144c9defac04969c7bfad8efaa8ea194'
    s3o.save!

    XmlAdapter.multipart_initialization(s3o)
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

    XmlAdapter.uploaded_object("#{@request.host}:#{@request.port}", s3o)
  end

  def handle_bucket
    unless (bucket = Bucket.find_by(name: @params[:bucket]))
      # Create if not exists facilities
      bucket = Bucket.create!(name: @params[:bucket])
    end
    bucket
  end
end
