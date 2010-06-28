# Put your extension routes here.

# map.namespace :admin do |admin|
#   admin.resources :whatever
# end  

map.resources :orders do |order|
  order.resource :checkout, :member => { :mpay_checkout => :any,
                                         :mpay_payment => :any,
                                         :mpay_confirm => :any,
                                         :mpay_finish => :any
                                       }
end

map.resources :mpay_express_callbacks, :only => [:index]
