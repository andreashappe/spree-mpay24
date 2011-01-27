require 'net/https'
require 'uri'

# Integrate our payment gateway with spree. This is needed
# to allow configuration through spree's web interface, etc.
class BillingIntegration::Mpay < BillingIntegration

  preference :production_merchant_id, :string
  preference :test_merchant_id, :string
  preference :url, :string, :default =>  'http://trageboutiquedev.com/'
  preference :secret_phrase, :string

  TEST_REDIRECT_URL = 'https://test.mPAY24.com/app/bin/etpv5'
  PRODUCTION_REDIRECT_URL = 'https://www.mpay24.com/app/bin/etpv5'
  MPAY24_IP = "213.164.25.245"
  MPAY24_TEST_IP = "213.164.23.169"

  def provider_class
    ActiveMerchant::Billing::MpayGateway
  end

  def self.current
    BillingIntegration::Mpay.first(
                  :conditions => {
                        :environment => RAILS_ENV,
                        :active => true
                  })
  end

  def verify_ip(request)
    if request.env['REMOTE_ADDR'] != mpay24_ip
      raise "invalid originator IP of #{request.env['REMOTE_ADDR']} vs #{mpay24_ip}".inspect
    end
  end

  def find_order(tid)
    if prefers_secret_phrase?
      if tid.starts_with?(preferred_secret_phrase)
        tid = tid.gsub(/^#{preferred_secret_phrase}_/, "")
      else
        raise "unknown secret phrase: #{tid}".inspect
      end
    end

    Order.find(:first, :conditions => { :id => tid })
  end

  def gateway_url
    prefers_test_mode? ? TEST_REDIRECT_URL : PRODUCTION_REDIRECT_URL
  end

  def mpay24_ip
    prefers_test_mode? ? MPAY24_TEST_IP : MPAY24_IP
  end

  def merchant_id
    prefers_test_mode? ? preferred_test_merchant_id : preferred_production_merchant_id
  end

  # generate the iframe URL
  def generate_url(order)

    cmd = generate_mdxi(order)

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

  def parse_result(response)
    result = {}
    response.body.split('&').each do |part|
      key, value = part.split("=")
      result[key] = CGI.unescape(value)
    end

    result
  end

  def generate_tid(order_id)
    if prefers_secret_phrase?
      "#{preferred_secret_phrase}_#{order_id}"
    else
      order_id
    end
  end

  def send_request(merchant_id, cmd)
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
                  'OPERATION' => 'SELECTPAYMENT',
                  'MERCHANTID' => merchant_id,
                  'MDXI' => cmd
    })

    http.request(request)
  end

  def generate_mdxi(order)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml.tag! 'Order' do
      xml.tag! 'Tid', generate_tid(order.id)
      xml.tag! 'ShoppingCart' do
        xml.tag! 'Description', order.number

        order.line_items.each do |li|
          xml.tag! 'Item' do
            xml.tag! 'Description', li.variant.product.name
            xml.tag! 'Quantity', li.quantity
            xml.tag! 'ItemPrice', sprintf("%.2f", li.price)
          end
        end

        order.update_totals

        xml.tag! 'Tax', sprintf("%.2f", order.tax_total)

        # TODO is this the same as order.credit_total?
        discounts = order.coupon_credits.sum(:amount)
        xml.tag! 'Discount', sprintf("%.2f", discounts)

        xml.tag! 'ShippingCosts', sprintf("%.2f", order.ship_total)
      end

      xml.tag! 'Price', sprintf("%.2f", order.total)

      xml.tag! 'BillingAddr', :Mode => 'ReadWrite' do
        xml.tag! 'Name', "#{order.ship_address.firstname} #{order.ship_address.lastname}"
        xml.tag! 'Street', order.bill_address.address1
        xml.tag! 'Street2', order.bill_address.address2
        xml.tag! 'Zip', order.bill_address.zipcode
        xml.tag! 'City', order.bill_address.city
        xml.tag! 'State', order.bill_address.state_name
        xml.tag! 'Country', order.bill_address.country.name
        xml.tag! 'Email', order.email
      end

      xml.tag! 'ShippingAddr', :Mode => 'ReadOnly' do
        xml.tag! 'Name', "#{order.ship_address.firstname} #{order.ship_address.lastname}"
        xml.tag! 'Street', order.ship_address.address1
        xml.tag! 'Street2', order.ship_address.address2
        xml.tag! 'Zip', order.ship_address.zipcode
        xml.tag! 'City', order.ship_address.city
        xml.tag! 'State', order.ship_address.state_name
        xml.tag! 'Country', order.ship_address.country.name
        xml.tag! 'Email', order.email
      end
      xml.tag! 'URL' do
        xml.tag! 'Success', "#{preferred_url}/mpay_callbacks"
        xml.tag! 'Confirmation', "#{preferred_url}/mpay_confirmation"
      end
    end

    xml.target!
  end
end
