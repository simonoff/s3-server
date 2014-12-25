class PerformCreate
  def self.call(params, request)
    PerformCreate.new(params, request).call
  end

  def initialize(params, request)
    @params = params
    @request = request
  end

  def call
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

  private

  def handle_bucket
    unless (bucket = Bucket.find_by(name: @params[:path]))
      # Create if not exists facilities
      bucket = Bucket.create!(name: @params[:path])
    end
    bucket
  end
end
