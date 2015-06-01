# == Schema Information
#
# Table name: s3_objects
#
#  id           :integer          not null, primary key
#  uri          :string
#  key          :string
#  size         :integer
#  md5          :string
#  content_type :string
#  file         :string
#  bucket_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class S3Object < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  belongs_to :bucket

  mount_uploader :file, FileUploader

  validates :uri, uniqueness: true
end
