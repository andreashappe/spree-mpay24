module MpayHelper
  def humanize_p_type(p_type)
    case p_type
    when "CC"
      t('CC')
    else
      t('Uknown')
    end
  end
  
  def payment_method(order)
    return "" unless order
    return "" if order.checkout.payments.empty?
    return "" if order.checkout.payment.source.nil?
    return "" unless order.checkout.payment.source.is_a?(MPaySource)
    
    "#{humanize_p_type(order.checkout.payment.source.p_type)}: #{order.checkout.payment.source.brand}"
  end
end
