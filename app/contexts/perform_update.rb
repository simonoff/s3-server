class PerformUpdate
  DISPATCHER = Hash.new { |h, k| h[k] = "perform_#{k}" }

  def self.call(params)
    PerformUpdate.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    send(DISPATCHER[@params[:s3_action_perform]])
  end

  private

  def perform_create_bucket
    Bucket.create!(name: @params[:bucket]) unless Bucket.find_by(name: @params[:bucket])
    [:created, :xml, XmlAdapter.created_bucket(Bucket.find_by(name: @params[:bucket]))]
  end

  # For singlepart upload
  # http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpREST.html
  def perform_store_object
    s3o = S3Object.find_by(uri: @params[:s3_object_uri]) || S3Object.new
    s3o.uri = @params[:s3_object_uri]
    s3o.file = @params[:file]
    s3o.bucket = handle_bucket
    s3o.key = @params[:key]
    s3o.content_type = @params[:file].content_type
    s3o.size = File.size(s3o.file.path)
    s3o.md5 = Digest::MD5.file(s3o.file.path).hexdigest
    s3o.save!

    [:ok, :head, s3o.md5]
  end

  def perform_s3_multipart_upload
    unless S3Object.find(@params['uploadId'].to_s)
      return :not_found, :xml, XmlAdapter.error_no_such_key(@params[:key])
    end

    dir = File.join('tmp', 'multiparts', "s3o_#{@params['uploadId']}")
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    path = File.join(dir, "part_#{@params['partNumber']}.raw")
    File.open(path, 'wb') do |part|
      part << @params[:request_body].read
    end

    [:ok, :head, Digest::MD5.file(path).hexdigest]
  end

  def perform_copy
    fail 'NotImplemetedYet'
  end

  private

  def handle_bucket
    unless (bucket = Bucket.find_by(name: @params[:bucket]))
      # Create if not exists facilities
      bucket = Bucket.create!(name: @params[:bucket])
    end
    bucket
  end
end
