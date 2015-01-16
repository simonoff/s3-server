class Bucket < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  belongs_to :user
  has_many :s3_objects, dependent: :destroy
  has_one :acl, dependent: :destroy
end
