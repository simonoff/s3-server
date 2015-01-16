class S3Object < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  belongs_to :bucket

  mount_uploader :file, FileUploader

  validates :uri, uniqueness: true
end
