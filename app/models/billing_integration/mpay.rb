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
    xml.tag! 'order' do
      xml.tag! 'Tid', 'some order identifier'
      xml.tag! 'ShoppingCart' do
        xml.tag! 'Description', 'some description'
      end

      xml.tag! 'price', 14.5
      xml.tag! 'BillingAddr', :mode => 'ReadWrite' do
        xml.tag! 'Name', 'Testname'
        xml.tag! 'Street', 'some street'
        xml.tag! 'City', 'some city'
#        xml.tag! 'Name', "#{order.ship_address.firstname} #{order.ship_address.lastname}"
#        xml.tag! 'City', order.ship_address.city
#        xml.tag! 'Street', order.ship_address.street
        #TODO: add more address stuff from options hash
      end

      xml.tag! 'URL' do
        xml.tag! 'Confirmation', 'some-confirmation-url'
        xml.tag! 'Notifcation', 'the-callback-url'
      end
    end

    cmd = xml.build!

    # create the HTTP request
    # TODO: use the certificate for authentication
    url = URI.parse(gateway_url)
    request = Net::HTTP::Post.new(url.path,{"Content-Type"=>"text/xml"})
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.set_debug_output $stderr

    request = Net::HTTP::Post.new(url.request_uri)
    request.set_form_data({
                  'OPERATION' => operation,
                  'MERCHANTID' => merchant_id,
                  'MDXI' => cmd
    })

    response = http.request(request)

    raise response.body.inspect
  end
end
