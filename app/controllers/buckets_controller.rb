class BucketsController < ApplicationController
  include CleanerManager

  before_action :find_user

  def index
    @buckets = Bucket.all
    render 'index.xml.builder'
  end

  def create
    @bucket = Bucket.find_by(name: params[:bucket_name]) ||
      Bucket.create!(name: params[:bucket_name], user: @user)
    render 'create.xml.builder'
  end

  def show
    @bucket = Bucket.find_by(name: params[:bucket_name]) ||
      Bucket.create!(name: params[:bucket_name], user: User.create!)
    render 'show.xml.builder'
  end

  def destroy
    @bucket = Bucket.find_by(name: params[:bucket_name])

    if @bucket && @bucket.s3_objects.blank?
      @bucket.destroy

      head :no_content
    elsif @bucket
      @error = Error.create(code: 'BucketNotEmpty',
                            message: 'The bucket you tried to delete is not empty.',
                            resource: 'bucket')
      render 'errors/show.xml.builder', status: :unprocessable_entity
    else
      @error = Error.create(code: 'NoSuchBucket', resource: params[:bucket_name],
                            message: 'The resource you requested does not exist')
      render 'errors/show.xml.builder', status: :not_found
    end
  end

  private

  def find_user
    @user = User.first || User.create!
  end
end
