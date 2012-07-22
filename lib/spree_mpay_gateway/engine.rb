module SpreeMpayGateway
  class Engine < Rails::Engine
    engine_name 'spree_mpay_gateway'
    #isolate_namespace Spree

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree.mpay_gateway.activation", :after => "spree.register.payment_methods" do |app|
      # integrate our god-frickin' view helper
      Spree::BaseController.class_eval do
        helper MpayHelper
      end
    end

    # load billing integration module
    config.after_initialize do |app|
      app.config.spree.payment_methods += [
        Spree::BillingIntegration::Mpay
      ]
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
