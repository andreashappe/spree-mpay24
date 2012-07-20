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

  def spree_mpay_iframe(order, width=680, height=500)
    mpay = Spree::BillingIntegration::Mpay.where(:active => true).where(:environment => Rails.env.to_s).first
    "<iframe src=\"#{mpay.generate_url(@order)}\" width=#{width}px height=#{height}px></iframe>".html_safe
  end
end
