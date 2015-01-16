class Acl < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  belongs_to :buckey
end
