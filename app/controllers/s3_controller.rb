class S3Controller < ApplicationController
  def index
    RequestNormalizer.normalize_index(params, request)
    status, render_type, body = PerformIndex.call(params)
    render render_type => body, status: status
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
