# == Schema Information
#
# Table name: buckets
#
#  id         :integer          not null, primary key
#  name       :string
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Bucket < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  belongs_to :user
  has_many :s3_objects, dependent: :destroy
  has_one :acl, dependent: :destroy
end
