# TODO: howto secure this controller?
# TODO: can we check againt an IP block?
# TODO: integrate this controller into the appliation
class MpayConfirmationController < Controller < Admin::BaseController

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

        # do the state change
        if order.price == params["PRICE"]
          order.pay
          order.save!
        elsif order.price < params["PRICE"]
          order.over_pay
          order.save!
        elsif order.price > params["PRICE"]
          order.under_pay
          order.save!
        end
      end
    else
      raise "what is going on?".inspect
    end

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
    if !params.include?(tid) || !(order = Order.find(tid)).nil?
      raise "could not find order: #{tid}".inspect
    end

    return order
  end

  def verify_currency(order, currency)
    order.currency == currency
  end
end
