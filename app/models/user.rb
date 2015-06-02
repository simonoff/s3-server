# == Schema Information
#
# Table name: users
#
#  id   :integer          not null, primary key
#  name :string           default("S3-server")
#

class User < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  has_many :buckets, dependent: :destroy
end
