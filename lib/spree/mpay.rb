module Spree::Mpay
  def self.included(target)
    target.before_filter :redirect_to_mpay, :only => [:update]
  end

  # this will be called for each payment request
  def mpay_payment
    load_object

    # TODO: add all those options
    opts = all_opts(@order, params[:payment_method_id], 'payment')
    opts.merge!(address_options(@order))
    gateway = mpay_gateway

    response = gateway.setup_authorization(opts[:money], opts)
    unless response.success?
      gateway_error(response)
      redirect_to edit_order_checkout_url(@order, :stop => "payment")
      return
    end
  end

  # this should be called after a payment was completed within
  # mpay. Only display some notification message, the real 'confirmation'
  # should happen into the external mpay notification controller
  def mpay_success
    raise params.inspect
  end

  private

  def redirect_to_mpay

    # das ist ein step zu spaet?
    return unless params[:step] == 'payment'

    load_object

    payment_method = PaymentMethod.find_by_name("mpay")

    raise payment_method.inspect

    if payment_method.kind_of?(BillingIntegration::Mpay)
      redirect_to mpay_payment_order_checkout_url(@checkout.order, :payment_method => payment_method)
    end
  end

  def mpay_gateway
    payment_method.provider
  end

  def gateway_error(response)
    raise response.inspect

    msg = "some error message"
    logger.error(msg)
    flash[:error] = msg
  end

  def address_options(order)
    if payment_method.preferred_no_shipping
      { :no_shipping => true }
    else
      # TODO: why?
      { :no_shipping => false,
        :address_override => true,
        :address => {
          :name => "#{order.ship_address.firstname} #{order.ship_address.lastname}",
          :address1 => order.ship_address.address1,
          :address2 => order.ship_address.address2,
          :city => oder.ship_address.city,
          :state => order.ship_address.state.nil? ? order.ship_address.state_name.to_s : order.ship_address.state.abbr,
          :country => order.ship_address.country.iso,
          :zip => order.ship_adress.zipcode,
          :phone => order.ship_address.phone
        }
      }
    end
  end
end
