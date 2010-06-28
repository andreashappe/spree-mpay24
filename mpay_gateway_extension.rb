# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class MpayGatewayExtension < Spree::Extension
  version "0.1"
  description "MPay24.at payment gateway intergration"
  url "http://starseeders.net"

  def activate
    # load billing stuff
    BillingIntegration::MPay.register
   
    # integrate custom checkout/payment logic
    CheckoutsController.class_eval do
      include Spree::MPay
    end
  end
end
