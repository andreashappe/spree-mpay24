# Integrate our payment gateway with spree. This is needed
# to allow configuration through spree's web interface, etc.
class BillingIntegration::Mpay < BillingIntegration

  # TODO: add the right preferences, and howto access them from
  # TODO: the real gateway interface code?
  preference :merchant_id, :string
  preference :password, :string
  preference :test_merchant_id, :string
  preference :test_merchant_password, :string

  def provider_class
    ActiveMerchant::Billing::MpayGateway
  end
end
