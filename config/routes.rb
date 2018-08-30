Rails.application.routes.draw do
  
  get '/tree/:name' => 'api#tree'

end
