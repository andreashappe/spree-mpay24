Spree::Core::Engine.routes.draw do
  resources :mpay_callbacks, :only => [:index]
  resource :mpay_confirmation, :controller => 'mpay_confirmation', :only => [:show]
end
