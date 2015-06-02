# == Schema Information
#
# Table name: acls
#
#  id         :integer          not null, primary key
#  name       :string           default("You")
#  permission :string           default("FULL_CONTROL")
#  bucket_id  :integer
#

class Acl < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  belongs_to :buckey
end
