class PerformDestroy
  DISPATCHER = Hash.new { |h, k| h[k] = "perform_#{k}" }

  def self.call(params)
    PerformDestroy.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    send(DISPATCHER[@params['s3_action_perform']])
    remove_empty_directories
  end

  private

  def perform_rm_bucket
    if (bucket = Bucket.find_by(name: @params['path']))
      bucket.destroy
    end
  end

  def perform_rm_object
    uri = "#{@params['path']}.#{@params['format']}"
    if (s3o = S3Object.find_by(uri: uri))
      s3o.destroy
    end
  end

  def remove_empty_directories
    until (empty_dirs = find_empty_directories).empty?
      empty_dirs.each   { |d| Dir.rmdir d }
    end
  end

  def find_empty_directories
    Dir["#{Rails.application.secrets[:storage][:base_dir]}/**/*"]
      .select { |d| File.directory? d }
      .select { |d| (Dir.entries(d) - %w(. ..)).empty? }
  end
end
