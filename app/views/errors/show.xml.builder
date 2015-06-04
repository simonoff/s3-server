xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8') unless @error.resource =~ /in copy|in multipart_completion/
xml.Error do |err|
  err.Code @error.code
  err.Message @error.message
  err.Resource @error.resource
  err.RequestId @error.request_id
  err.HostId 'Uuag1LuByRx9e6j5Onimru9pO4ZVKnJ2Qz7/C1NPcfTWAtRPfTaOFg=='
end
