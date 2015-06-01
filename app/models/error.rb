# == Schema Information
#
# Table name: errors
#
#  id         :integer          not null, primary key
#  code       :string
#  message    :string
#  resource   :string
#  request_id :integer          default(1)
#

class Error < ActiveRecord::Base
  include ActiveModel::Serializers::Xml
end
