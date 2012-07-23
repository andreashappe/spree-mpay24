#require File.dirname(__FILE__) + '/../spec_helper'

require 'spec_helper'

describe MpayCallbacksController, "the callback return-screen of the shop" do

  let(:user) { create(:user) }
  let(:order) { user.orders.create }

  it "should work if the user was logged in" do
    controller.stub :current_user => user
    Spree::BillingIntegration::Mpay.current.stub :find_order => order

    spree_get :index, {"TID"=>"assdf_#{order.number}", "LANGUAGE"=>"DE", "USER_FIELD"=>"", "BRAND"=>"VISA"}

    response.should render_template("spree/shared/mpay_success")
  end

  it "should work if the user isn't logged in" do
    controller.stub :current_user => nil
    Spree::BillingIntegration::Mpay.current.stub :find_order => order

    spree_get :index, {"TID"=>"assdf_#{order.number}", "LANGUAGE"=>"DE", "USER_FIELD"=>"", "BRAND"=>"VISA"}

    response.should render_template("spree/shared/mpay_success")
  end
end
