class MpayCallbacksController < Spree::BaseController
  def index
    order = Order.find(:first, :conditions => { :id => params["TID"]})

    if order
      if order.state == "in_progress"
        order.complete!
      end

      if order.state == "new"
        order.pay!
      end

      render :partial => 'shared/mpay_success',
             :locals => { :order => order }
    else
      raise params.inspect
    end
  end
end
