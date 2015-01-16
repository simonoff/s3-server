class AclsController < ApplicationController
  before_action :find_bucket

  def create
    @acl = Acl.create!(name: params[:name], user_id: @user.id)
  end

  def show
    @acl = @bucket.acl
  end

  private

  def find_bucket
    Bucket.find_by(name: params[:bucket_name])
  end
end
