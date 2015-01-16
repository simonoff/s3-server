Rails.application.routes.draw do
  get '/', to: 'buckets#index'
  get '/:bucket_name', to: 'buckets#show', constraints: ->(req) { req.query_parameters['versioning'] }
  put '/:bucket_name', to: 'buckets#create', constraints: ->(req) { req.query_parameters.blank? }
  delete '/:bucket_name', to: 'buckets#destroy'

  put '/:bucket_name(/*path)', to: 'acl#create', constraints: ->(req) { req.query_parameters['acl'] }
  get '/:bucket_name(/*path)', to: 'acl#show', constraints: ->(req) { req.query_parameters['acl'] }

  put '/:bucket_name/*path', to: 's3_objects#copy', constraints: ->(req) { req.headers['x-amz-copy-source'] }

  put '/:bucket_name/*path', to: 's3_objects#part_upload', constraints: ->(req) { req.query_parameters['uploadId'] && req.query_parameters['partNumber'] }
  put '/:bucket_name/*path', to: 's3_objects#singlepart_upload'
  post '/:bucket_name/:key_name(/*path)', to: 's3_objects#create', constraints: ->(req) { req.query_parameters['uploads'] }
  post '/:bucket_name/:key_name(/*path)', to: 's3_objects#multipart_completion', constraints: ->(req) { req.query_parameters['uploadId'] }
  post '/:bucket_name(/*path)', to: 's3_objects#multipart_upload'
  delete '/:bucket_name/*path', to: 's3_objects#multipart_abortion', constraints: ->(req) { req.query_parameters['uploadId'] }
  get '/:bucket_name', to: 's3_objects#index'
  match '/:bucket_name/*path', to: 's3_objects#show', via: [:get, :head]
  delete '/:bucket_name/:key_name(/*path)', to: 's3_objects#destroy'

  match '*path', to: 'application#routing_error', via: :all
end
