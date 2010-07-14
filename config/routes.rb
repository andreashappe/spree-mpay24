# will be used for sucess messages
map.resources :mpay_callbacks, :only => [:index]

# this is used to confirm payed orders
map.resource :mpay_confirmation, :controller => 'mpay_confirmation', :only => [:show]
