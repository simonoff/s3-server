xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.Error do |err|
  err.Code @error.code
  err.Message @error.message
  err.Resource @error.resource
  err.RequestId @error.request_id
end
