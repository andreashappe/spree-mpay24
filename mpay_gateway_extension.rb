# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class MpayGatewayExtension < Spree::Extension
  version "0.1"
  description "MPay24.at payment gateway intergration"
  url "http://starseeders.net"

  def activate

    # load billing stuff
    BillingIntegration::Mpay.register
   
    # integrate our god-frickin' view helper
    Spree::BaseController.class_eval do
      helper MpayHelper
    end
  end
end

