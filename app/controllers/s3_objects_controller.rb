class S3ObjectsController < ApplicationController
  include ActionController::Live
  include CleanerManager

  before_action :find_bucket, except: :part_upload

  def index
    @s3_objects = @bucket.s3_objects
    render 'index.xml.builder'
  end

  def create
    @s3_object = S3Object.find_by(uri: uri) || S3Object.new
    @s3_object.update_attributes(
      bucket: @bucket, uri: uri, key: key, md5: nil, size: nil, file: nil,
      content_type: request.content_type || 'application/octet-stream')
    render 'create.xml.builder'
  end

  def show
    @s3_object = S3Object.find_by(uri: uri)

    if @s3_object && File.exist?(@s3_object.file.path)
      case request.method
      when 'HEAD'
        response.headers.tap do |hs|
          hs['Content-Type'] = @s3_object.content_type
          hs['Content-Length'] = @s3_object.size.to_s
        end
        head :ok
      when 'GET'
        send_file(@s3_object.file.path,
                  type: @s3_object.content_type, disposition: 'attachment',
                  stream: true, buffer_size: 4096, url_based_filename: false)
      end
    else
      @error = Error.create(code: 'NoSuchKey', resource: 's3_object',
                            message: 'The specified key does not exist')
      render 'errors/show.xml.builder', status: :not_found
    end
  end

  def multipart_completion
    @s3_object = S3Object.find(request.query_parameters['uploadId'])

    mp = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        MultipartCompletion.call(@s3_object, request.body.read)
        @s3_object.file.filename = filename
        @s3_object.save
      end
    end
    mp.abort_on_exception = true

    response.headers['Content-Type'] = 'text/event-stream'
    while mp.alive?
      # Periodically sends whitespace characters to keep the connection from timing out
      response.stream.write ''
      sleep(5)
    end
    mp.join # Ensure multipart completion is finished

    template = Tilt.new('app/views/s3_objects/multipart_completion.xml.builder')
    response.stream.write template.render(self)
    response.stream.close
  end

  def part_upload
    etag = PartUpload.call(request.query_parameters['uploadId'],
                           request.query_parameters['partNumber'], request.body.read)
    response.headers.tap do |hs|
      hs['ETag'] = etag
    end
    render plain: '', status: :ok
  end

  def multipart_upload
    @s3_object = S3Object.find_by(uri: uri) || S3Object.new

    params[:key] ||= key
    if params[:key].split('/').last.eql? '${filename}'
      params[:key].sub!('${filename}', file.original_filename)
    else
      file.original_filename = params[:key].split('/').last
    end

    @s3_object.update_attributes(
      uri: "#{@bucket.name}/#{params[:key]}", bucket: @bucket, key: params[:key],
      file: file, content_type: file.content_type,
      size: File.size(file.path), md5: Digest::MD5.file(file.path).hexdigest)

    render 'multipart_upload.xml.builder', status: :created
  end

  def singlepart_upload
    @s3_object = S3Object.find_by(uri: uri) || S3Object.new
    @s3_object.update_attributes(
      bucket: @bucket, uri: uri, key: key, size: file.size, content_type: file.content_type,
      file: file, md5: Digest::MD5.file(file.path).hexdigest)

    response.headers.tap do |hs|
      hs['ETag'] = @s3_object.md5
    end
    render plain: '', status: :ok
  end

  def copy
    if source.blank?
      head :no_content
    else
      src_elts = source.split('/')
      root_offset = src_elts.first.empty? ? 1 : 0

      src_bucket = src_elts[root_offset]
      src_key = src_elts[(1 + root_offset)..-1].join('/')
      src_uri = src_bucket + '/' + src_key

      cp = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          @src_s3_object = S3Object.find_by(uri: src_uri)
          @s3_object = CopyObject.call(@src_s3_object, uri, filename, @bucket, key)
        end
      end
      cp.abort_on_exception = true

      response.headers['Content-Type'] = 'text/event-stream'
      while cp.alive?
        # Periodically sends whitespace characters to keep the connection from timing out
        response.stream.write ''
        sleep(5)
      end
      cp.join # Ensure object copy is finished

      template = Tilt.new('app/views/s3_objects/copy.xml.builder')
      response.stream.write template.render(self)
      response.stream.close
    end
  end

  def multipart_abortion
    @s3_object = S3Object.find_by(uri: uri)

    @s3_object.destroy if @s3_object
    if Dir.exist?((dir = File.join('tmp', 'multiparts', "s3o_#{@s3_object.id}")))
      FileUtils.rm_r(dir)
    end

    head :no_content
  end

  def destroy
    @s3_object = S3Object.find_by(uri: uri) || S3Object.find(request.query_parameters['uploadId'])
    @s3_object.destroy
    head :no_content
  end

  private

  def find_bucket
    @bucket ||= Bucket.find_by(name: params[:bucket_name]) ||
      Bucket.create!(name: params[:bucket_name], user: User.create!)
  end

  def source
    @source ||= request.headers['x-amz-copy-source']
  end

  def uri
    @uri ||= request.path[1..-1].split('?').first
  end

  def key
    @key ||= uri.split('/')[1..-1].join('/')
  end

  def filename
    @filename ||= key.split('/').last
  end

  def file
    @file ||= params[:file] || ActionDispatch::Http::UploadedFile.new(
      tempfile: tmpfile, filename: filename, head: file_headers,
      type: request.content_type || 'application/octet-stream')
  end

  def tmpfile
    tmpfile = Tempfile.new(filename)
    tmpfile.binmode
    tmpfile.write(request.body.read)
    tmpfile.rewind
    tmpfile
  end

  def file_headers
    "Content-Disposition: form-data; name=\"file\"; filename=\"noname.txt\"\r\n" \
      "Content-Type: #{request.content_type || 'application/octet-stream'}\r\n"
  end
end
