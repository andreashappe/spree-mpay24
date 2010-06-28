# adapt routes to mpay
map.resources :orders do |order|
  order.resource :checkout, :member => { #:mpay_checkout => :any,
                                         :mpay_payment => :any,
                                         :mpay_success => :any
                                         #:mpay_confirm => :any,
                                         #:mpay_finish => :any
                                       }
end

map.resources :mpay_callbacks, :only => [:index]
