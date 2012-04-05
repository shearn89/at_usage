Website::Application.routes.draw do
  get "errors/404"
  get "errors/500"
  
  # image data
  match '/machines/spark_data', :controller => 'machines', :action => 'spark_data'
  
  # api requests and general navigation
  match '/all', :to => 'machines#info', :flag => 'all'
  match '/available', :to => 'machines#info', :flag => 'available'
  match '/stale', :to => 'machines#info', :flag => 'stale'
  match '/asleep', :to => 'machines#info', :flag => 'asleep'
  
  match '/machines/all', :to => 'machines#info', :flag => 'all'
  match '/machines/available', :to => 'machines#info', :flag => 'available'
  match '/machines/stale', :to => 'machines#info', :flag => 'stale'
  match '/machines/asleep', :to => 'machines#info', :flag => 'asleep'
  
  match '/machine/:id', :to => 'machines#show'
  match '/lab/:floor/:lab', :to => 'machines#info'
  match '/floor/:floor', :to => 'machines#info'
  
  # mailer handling
  match '/contact', :to => 'machines#contact', :as => 'contact'
  match '/dispatch_email', :to => 'machines#dispatch_email', :as => 'dispatch_email', :method => :post
  
  # other
  resources :machines
  root :to => 'machines#index'
  
  # static
  match '/api' => 'static#api'
  
  # RoutingError fix
  match "*a" => 'errors#render_not_found'
end
