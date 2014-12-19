class S3Controller < ApplicationController
  def index
    RequestNormalizer.normalize_index(params, request)
    status, render_type, data = PerformIndex.call(params)
    if render_type == :file
      send_file(data.file.path,
                type: data.content_type,
                disposition: 'attachment',
                stream: true,
                buffer_size: 4096,
                url_based_filename: false)
    else
      render render_type => data, status: status
    end
  end

  def create
    RequestNormalizer.normalize_create(params)
    render xml: PerformCreate.call(request, params), status: :created
  end

  def update
    render json: '{}'
  end

  def destroy
    render json: '{}'
  end
end
