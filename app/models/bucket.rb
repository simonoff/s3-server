class Bucket < ActiveRecord::Base
  include BucketQuery

  has_many :s3_objects, dependent: :destroy
end
