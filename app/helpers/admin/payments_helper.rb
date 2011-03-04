module Admin::PaymentsHelper
  def payment_method_name(payment)
    # hack to allow us to retrieve the name of a "deleted" payment method
    id = payment.payment_method_id
    # hack because the payment method is not set in the mpay confirmation controller. fix it
    if id == nil then
      PaymentMethod.find_by_id(842616224).name
    else
     
      # TODO: include destroyed payment methods
      method = PaymentMethod.find_by_id(id)

      # somehow we've got invalid payment methods in our system
      if method.nil?
        PaymentMethod.find_by_id(842616224).name
      else
        method.name
      end
    end
  end
end
