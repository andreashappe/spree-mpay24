require 'spec_helper'

describe MpayHelper do
  describe "#spree_mpay_iframe" do

    let(:user) { create(:user) }

    it "should not proceed if the order's state != payment" do
      order = user.orders.create
      
      lambda do
        spree_mpay_iframe(order)
      end.should raise_error "order #{order.id} not in state payment but in #{order.state}" 
    end
  end
end
