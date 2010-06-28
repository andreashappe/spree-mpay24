module ActiveMerchant
  module Billing
    class MPayGateway < Gateway

      def setup_authorization(money, options = {})
        requires!(options, :return_url, :cancel_return_url)
        commit 'SetExpressCheckout', build_setup_request('Authorization', money, options)
      end

      def authorize(money, options={})
        raise "mpaygateway.authorize called".inspect
      end

      def purchase(money, options={})
        raise "mpaygateway.purchase called".inspect
      end

      private

      def build_setup_request(action, money, options)
        # TODO: build XML for setup request?
      end
    end
  end
end
