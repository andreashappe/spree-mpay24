require 'net/https'
require 'uri'

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

  def self.test_mode
    true
  end

  TEST_REDIRECT_URL = 'https://test.mPAY24.com/app/bin/etpv5'
  PRODUCTION_REDIRECT_URL = 'https://www.mpay24.com/app/bin/etpv5'

  # TODO this should be preferences
  #self.production_merchant_id = '72035'
  #self.test_merchant_id = '92035'
  
  def self.gateway_url
    test_mode == true ? TEST_REDIRECT_URL : PRODUCTION_REDIRECT_URL
  end

  # generate the iframe URL
  def self.generate_url(order)
    # TODO: where to get options?

    # TODO: howto use the options infrastructure
    merchant_id = '92035'
    operation = 'SELECTPAYMENT'

    # TODO: merge options

    # build MDXI XML Block
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml.tag! 'Order' do
      xml.tag! 'Tid', 'some order identifier'
      xml.tag! 'ShoppingCart' do
        xml.tag! 'Description', 'some description'

        xml.tag! 'Item' do
          xml.tag! 'Description', 'Some Item'
          xml.tag! 'Quantity', 4
          xml.tag! 'ItemPrice', 10.11
        end

        xml.tag! 'Discount', -20.11
        xml.tag! 'ShippingCosts', 100.42
        xml.tag! 'Tax', 22.44
      end

      xml.tag! 'Price', sprintf("%.2f",14.5)
      xml.tag! 'BillingAddr', :Mode => 'ReadWrite' do
        xml.tag! 'Name', 'Testname'
        xml.tag! 'Street', 'some street'
        xml.tag! 'Street2', ''
        xml.tag! 'Zip', '1040'
        xml.tag! 'City', 'some city'
        xml.tag! 'State', ''
        xml.tag! 'Country', 'Austria'
        xml.tag! 'Email', ''
      end

      xml.tag! 'ShippingAddr', :Mode => 'ReadOnly' do
        xml.tag! 'Name', 'Testname'
        xml.tag! 'Street', 'some street'
        xml.tag! 'Street2', ''
        xml.tag! 'Zip', '1040'
        xml.tag! 'City', 'some city'
        xml.tag! 'State', ''
        xml.tag! 'Country', 'Austria'
        xml.tag! 'Email', ''
      end
      xml.tag! 'URL' do
        xml.tag! 'Success', 'some-confirmation-url'
        xml.tag! 'Confirmation', 'the-callback-url'
      end
    end

    cmd = xml.target!

    # create the HTTP request
    # TODO: use the certificate for authentication
    url = URI.parse(gateway_url)
    request = Net::HTTP::Post.new(url.path,{"Content-Type"=>"text/xml"})
    http = Net::HTTP.new(url.host, url.port)

    # verify through SSL
    http.use_ssl = true
    http.ca_path = "/etc/ssl/certs/"
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.verify_depth = 5

    request = Net::HTTP::Post.new(url.request_uri)
    request.set_form_data({
                  'OPERATION' => operation,
                  'MERCHANTID' => merchant_id,
                  'MDXI' => cmd
    })

    response = http.request(request)

    # parse result
    result = {}
    response.body.split('&').each do |part|
      key, value = part.split("=")
      result[key] = CGI.unescape(value)
    end

    # if everything did work: return the link url. Otherwise
    # output an ugly exception (at least we will get notified)
    if result["STATUS"] == "OK" && result["RETURNCODE"] == "REDIRECT"
      return result["LOCATION"].chomp
    else
      raise response.body.inspect
    end
  end
end
