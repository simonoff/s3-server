class S3Controller < ApplicationController
  def index
    RequestNormalizer.normalize_index(params, request)
    status, render_type, data = PerformIndex.call(params)
    case render_type
    when :file
      send_file(data.file.path,
                type: data.content_type, disposition: 'attachment',
                stream: true, buffer_size: 4096, url_based_filename: false)
    when :head
      response.headers.tap do |hs|
        hs['Content-Type'] = data.content_type
        hs['Content-Length'] = data.size.to_s
      end
      head :ok
    else
      render render_type => data, status: status
    end
  end

  def create
    RequestNormalizer.normalize_create(params, request)
    status, render_type, data = PerformCreate.call(params, request)
    render render_type => data, status: status
  end

  def update
    RequestNormalizer.normalize_update(params, request)
    status, render_type, data = PerformUpdate.call(params)
    case render_type
    when :head
      response.headers.tap do |hs|
        hs['ETag'] = data
      end
      head status
    else
      render render_type => data, status: status
    end
  end

  def destroy
    RequestNormalizer.normalize_destroy(params, request)
    PerformDestroy.call(params)
    head :no_content
  end
end
