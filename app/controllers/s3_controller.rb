class S3Controller < ApplicationController
  def index
    show
  end

  def show
    render json: '{"def":"show/index"}'
  end

  def create
    render xml: PostRequest.call(request, params)
  end

  def update
    render json: '{}'
  end

  def destroy
    render json: '{}'
  end
end
