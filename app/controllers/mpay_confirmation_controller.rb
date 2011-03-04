class MpayConfirmationController < Spree::BaseController

  # possible transaction states
  TRANSACTION_STATES = ["ERROR", "RESERVED", "BILLED", "REVERSED", "CREDITED", "SUSPENDED"]

  # Confirmation interface is a GET request
  def show

    BillingIntegration::Mpay.current.verify_ip(request)

    check_operation(params["OPERATION"])
    check_status(params["STATUS"])

    # get the order
    order = BillingIntegration::Mpay.current.find_order(params["TID"])

    case params["STATUS"]
    when "BILLED"
      # check if the retrieved order is the same as the outgoing one
      if verify_currency(order, params["CURRENCY"])

        # create new payment object
        payment_details = MPaySource.create ({
          :p_type => params["P_TYPE"],
          :brand => params["BRAND"],
          :mpayid => params["MPAYTID"]
	})

        payment_details.save!

        payment_method = PaymentMethod.where(:type => "BillingIntegration::Mpay").where(:environment => RAILS_ENV.to_s).first

        # TODO log the payment
        order.checkout.payments.create({
          :amount => params["PRICE"],
          :payment_method_id => payment_method,
          :source => payment_details
	})

        payment = order.checkout.payments.first
        payment.save!

        payment_details.payment = payment
        payment_details.save!

        price = order.total
        confirmed_price = params["PRICE"].to_i/100.0

        order.complete!

        # do the state change
        if price == confirmed_price
          order.pay!
        elsif price < confirmed_price
          order.over_pay!
        elsif price > confirmed_price
          order.under_pay!
        else
          raise "#{price} vs. #{confirmed price}".inspect
        end
      end
    when "RESERVED"
      raise "send the confirmation request out".inspect
    else
      raise "what is going on?".inspect
    end

    render :text => "OK", :status => 200
  end

  private

  def check_operation(operation)
    if operation != "CONFIRMATION"
      raise "unknown operation: #{operation}".inspect
    end
  end

  def check_status(status)
    if !TRANSACTION_STATES.include?(status)
      raise "unknown status: #{status}".inspect
    end
  end

  def find_order(tid)
    if (order = Order.find(tid)).nil?
      raise "could not find order: #{tid}".inspect
    end

    return order
  end

  def verify_currency(order, currency)
    "EUR" == currency
  end
end
