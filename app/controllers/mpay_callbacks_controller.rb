class MpayCallbacksController < Spree::BaseController
  def index

    @order = BillingIntegration::Mpay.current.find_order(params["TID"])
    
    order_params = {:checkout_complete => true}
    session[:order_id] = nil
    flash[:commerce_tracking] = "Track Me in GA"

    # TODO: this should not be rendered into the IFRAME but in the surrounding page
    # redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token})
    render :partial => "shared/mpay_success", :locals => { :final_url => order_url(@order, {:checkout_complete => true, :order_token => @order.token})}
  end
end
