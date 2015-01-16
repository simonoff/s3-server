class User < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  has_many :buckets, dependent: :destroy
end
