require 'spree_core'

class MpayGateway < Rails::Engine

  config.autoload_paths += %W(#{config.root}/lib)

  def self.activate
    
    Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
      Rails.env.production? ? require(c) : load(c)
    end
    
    # load billing stuff
    BillingIntegration::Mpay.register
   
    # integrate our god-frickin' view helper
    Spree::BaseController.class_eval do
      helper MpayHelper
    end
  end
  
  config.to_prepare &method(:activate).to_proc
end

