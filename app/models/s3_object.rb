class S3Object < ActiveRecord::Base
  belongs_to :bucket
  mount_uploader :file, FileUploader
end
