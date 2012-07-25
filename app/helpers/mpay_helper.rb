module MpayHelper
  def spree_mpay_iframe(order, width=680, height=500)

    raise "order #{order.id} not in state payment but in #{order.state}" if !order.payment?

    mpay = retreive_mpay_object
    content_tag :iframe, '', :src => mpay.generate_url(order), :height => "#{height}px", :width => "#{width}px"
  end

  private

  def retreive_mpay_object
    Spree::BillingIntegration::Mpay.where(:active => true).where(:environment => Rails.env.to_s).first
  end
end
