class Bucket < ActiveRecord::Base
  has_many :s3_objects
end
