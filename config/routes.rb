Rails.application.routes.draw do
  get '/', to: 's3#index'
  get '*path', to: 's3#index'
  post '*path', to: 's3#create'
  patch '*path', to: 's3#update'
  put '*path', to: 's3#update'
  delete '*path', to: 's3#destroy'
end
