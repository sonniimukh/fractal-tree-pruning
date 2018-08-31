Rails.application.routes.draw do
  
  get '/tree/:name' => 'api#tree', as: 'api_tree'

end
