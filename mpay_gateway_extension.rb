# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class MpayGatewayExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/mpay_gateway"

  # Please use mpay_gateway/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate

    BillingIntegration::MPay.register

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
   
    # add custom checkout code
    CheckoutsController.class_eval do
      include Spree::MPay
    end
  end
end
