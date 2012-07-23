#require File.dirname(__FILE__) + '/../spec_helper'

require 'spec_helper'

describe MpayConfirmationController, "receive payment notifications" do

  let(:user) { create(:user) }
  let(:order) { user.orders.create }

  it "should be able to do auto-clearing" do

    Spree::BillingIntegration::Mpay.current.stub :find_order => order

    options = {"OPERATION"=>"CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"RESERVED", "PRICE"=>"2529", "CURRENCY"=>"EUR", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}
    spree_get :show, options
    response.should be_success

    options["STATUS"] = "BILLED"
    spree_get :show, options
    response.should be_success

    closed_order = Spree::Order.find(order.id)
    raise closed_order.state.inspect
  end
end
