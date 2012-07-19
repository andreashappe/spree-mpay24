require 'net/https'
require 'uri'

module SpreeMpay
  class MpayCommunicator

    TEST_REDIRECT_URL = 'https://test.mPAY24.com/app/bin/etpv5'.freeze
    PRODUCTION_REDIRECT_URL = 'https://www.mpay24.com/app/bin/etpv5'.freeze

    def self.make_request(order, merchant_id, cmd, test_mode=true)
      # send the HTTP request
      response = send_request(merchant_id, cmd)

      result = parse_result(response)

      # if everything did work out: return the link url. Otherwise
      # output an ugly exception (at least we will get notified)
      if result["STATUS"] == "OK" && result["RETURNCODE"] == "REDIRECT"
        order.created_at = Time.now
        order.save!

        return result["LOCATION"].chomp
      else
        raise response.body.inspect
      end
    end

    private

    def self.send_request(merchant_id, cmd, test_mode=true)
      url = URI.parse(gateway_url(test_mode))
      request = Net::HTTP::Post.new(url.path,{"Content-Type"=>"text/xml"})
      http = Net::HTTP.new(url.host, url.port)

      # verify through SSL
      http.use_ssl = true
      http.ca_path = "/etc/ssl/certs/"
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_depth = 5

      request = Net::HTTP::Post.new(url.request_uri)
      request.set_form_data({
                    'OPERATION' => 'SELECTPAYMENT',
                    'MERCHANTID' => merchant_id,
                    'MDXI' => cmd
      })
      http.request(request)
    end

    def self.gateway_url(test_mode)
      test_mode ? TEST_REDIRECT_URL : PRODUCTION_REDIRECT_URL
    end

    def self.parse_result(response)
      result = {}

      #raise response.status.inspect

      #if response.status == :ok
        response.body.split('&').each do |part|
          key, value = part.split("=")
          result[key] = CGI.unescape(value)
        end
      #else
      #  raise response.inspect
      #end

      result
    end
  end
end
