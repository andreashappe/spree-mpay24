# TODO: howto secure this controller?
# TODO: can we check againt an IP block?
# TODO: integrate this controller into the appliation
class MpayConfirmationController < Spree::BaseController

  # possible transaction states
  TRANSACTION_STATES = ["ERROR", "RESERVED", "BILLED", "REVERSED", "CREDITED", "SUSPENDED"]

  # Confirmation interface is a GET request
  def show
    check_operation(params["OPERATION"])
    check_status(params["STATUS"])

    # get the order
    order = find_order(params["TID"])

    if params["STATUS"] == "BILLED"
      # check if the retrieved order is the same as the outgoing one
      if verify_currency(order, params["CURRENCY"])

        # TODO log the payment
        order.checkout.payments.create(
          :amount => params["PRICE"],
          :payment_method_id => nil
        )

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
    else
      raise "what is going on?".inspect
    end

    render :text => "OK", :status => 200

    # Other fields (how to use them?):
    # P_TYPE
    # BRAND
    # MPAYTID
    # USER_FIELD
    # LANGUAGE
    # APPR_CODE
    # PROFILE_STATUS
    # FILTER_STATUS
    # SUSPENDED_REASON
    # MSG
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
