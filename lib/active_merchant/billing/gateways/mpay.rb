module ActiveMerchant
  module Billing
    class MPayGateway < Gateway

      def authorize(money, options={})
        raise "mpaygateway.authorize called".inspect
      end

      def purchase(money, options={})
        raise "mpaygateway.purchase called".inspect
      end
    end
  end
end
