# Integrate our payment gateway with spree. This is needed
# to allow configuration through spree's web interface, etc.
class Spree::BillingIntegration::Mpay < Spree::BillingIntegration

  preference :production_merchant_id, :string
  preference :test_merchant_id, :string
  preference :url, :string, :default =>  'http://trageboutiquedev.com/'
  preference :secret_phrase, :string

  attr_accessible :preferred_production_merchant_id, :preferred_test_merchant_id,
                  :preferred_url, :preferred_secret_phrase, :preferred_server, :preferred_test_mode

  def provider_class
    ActiveMerchant::Billing::MpayGateway
  end

  def self.current
    Spree::BillingIntegration::Mpay.where(:active => true).where(:environment => Rails.env.to_s).first
  end

  def find_order(tid)
    if prefers_secret_phrase?
      if tid.starts_with?(preferred_secret_phrase)
        tid = tid.gsub(/^#{preferred_secret_phrase}_/, "")
      else
        raise "unknown secret phrase: #{tid}".inspect
      end
    end

    Spree::Order.find(:first, :conditions => { :id => tid })
  end


  # generate the iframe URL
  def generate_url(order)

    cmd = SpreeMpayGateway::XmlBuilder.generate_mdxi_for_order(order, preferred_url, preferred_secret_phrase)
    result_url = SpreeMpayGateway::MpayCommunicator.make_request(order, merchant_id, cmd, prefers_test_mode?)
   
    if !result_url.blank? 
      order.created_at = Time.now
      order.save!
      return result_url
    else
      raise "could not generate mpay iframe URL"
    end
  end

  private

  def merchant_id
    prefers_test_mode? ? preferred_test_merchant_id : preferred_production_merchant_id
  end
end
