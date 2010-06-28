class MpayCallbacksController < Controller < Admin::BaseController
  def index
    # there should be a 'TID' option which should map something within
    # our order database.. so we can dipslay the right confirmation
    raise params.inspect

    # TODO: also we should mark the payment/order as 'payed' somehow

    render :partial => 'shared/mpay_success',
           :locals => { :order => Order.find(params[:tid]) }
  end
end
