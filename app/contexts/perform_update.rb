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
    Bucket.create!(name: @params[:path]) unless Bucket.find_by(name: @params[:path])
  end

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
