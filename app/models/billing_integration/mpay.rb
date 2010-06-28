class BillingIntegration::Mpay < BillingIntegration

  preference :login, :string
  preference :password, :password

  def provider_class
    ActiveMerchant::Billing::MPayGateway
  end
end
