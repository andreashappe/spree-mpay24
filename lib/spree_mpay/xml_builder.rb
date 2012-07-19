require 'builder'

module SpreeMpay
  class XmlBuilder
    def self.generate_mdxi_for_order(order, response_url, secret)
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      xml.tag! 'Order' do
        xml.tag! 'Tid', generate_tid(order.id, secret)
        xml.tag! 'ShoppingCart' do
          xml.tag! 'Description', order.number

          order.line_items.each do |li|
            xml.tag! 'Item' do
              xml.tag! 'Description', li.variant.product.name
              xml.tag! 'Quantity', li.quantity
              xml.tag! 'ItemPrice', sprintf("%.2f", li.price)
            end
          end

          xml.tag! 'Tax', sprintf("%.2f", order.tax_total)

          # TODO is this the same as order.credit_total?
          discounts = order.adjustment_total - order.tax_total - order.ship_total

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
          xml.tag! 'Success', "#{response_url}/mpay_callbacks"
          xml.tag! 'Confirmation', "#{response_url}/mpay_confirmation"
        end
      end

      xml.target!
    end

    private

    def self.generate_tid(order_id, secret)
      if !secret.blank?
        "#{secret}_#{order_id}"
      else
        order_id
      end
    end
  end
end
