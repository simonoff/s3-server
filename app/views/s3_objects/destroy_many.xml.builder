xml.DeleteResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |dr|
  dr.Deleted do |del|
    @destroy_many[:deleted].each do |object|
      del.Key object[:key]
    end
  end unless @destroy_many[:deleted].empty?

  dr.Error do |err|
    @destroy_many[:errors].each do |err|
      err.Key object[:key]
      err.Code object[:code]
      err.Message object[:message]
    end
  end unless @destroy_many[:errors].empty?
end
