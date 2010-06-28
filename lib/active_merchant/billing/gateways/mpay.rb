require 'net/http'
require 'uri'

module ActiveMerchant
  module Billing
    class MPayGateway < Gateway

      self.test_redirect_url = '';
      self.redirect_url = '';

      def setup_authorization(money, options = {})
        # TODO: howto use the options infrastructure
        merchant_id = '123'
        operation = 'SELECTPAYMENT'

        # TODO: merge options

        # build MDXI XML Block
        xml = Bulder::XmlMarkup.new
        xml.tag! 'order' do
          xml.tag! 'Tid', 'some order identifier'
          xml.tag! 'ShoppingCart' do
            xml.tag! 'Description', 'some description'
          end

          xml.tag! 'price', amount(money)
          xml.tag! 'BillingAddr', :mode => 'ReadWrite' do
            xml.tag! 'Name', options[:shipping_address][:name]
            #TODO: add more address stuff from options hash
          end

          xml.tag! 'URL' do
            xml.tag! 'Confirmation', 'some-confirmation-url'
          end
        end

        cmd = xml.build!

        # build and send the command
        res = Net::HTTP.post_form(URI.parse(self.test_redirect_url),
                              {
                                'operation' => operation,
                                'merchant_id' => merchant_id,
                                'MDXI' => cmd
                              })

        # extract information
        raise res.inspect

    #3: Detailed control
    #url = URI.parse('http://www.example.com/todo.cgi')
    #req = Net::HTTP::Post.new(url.path)
    #req.basic_auth 'jack', 'pass'
    #req.set_form_data({'from'=>'2005-01-01', 'to'=>'2005-03-31'}, ';')
    #res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    #case res
    #when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
    #else
    #  res.error!
    #end
        
        # render the corresponding URL in an IFRAME
        render :partial => 'shared/mpay_confirm',
               :locals => { :iframe_url => "fubar" },
               :layout => true
      end

      def authorize(money, options={})
        raise "mpaygateway.authorize called".inspect
      end

      def purchase(money, options={})
        raise "mpaygateway.purchase called".inspect
      end
    end
  end
end
