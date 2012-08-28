require 'spec_helper'

describe MpayConfirmationController, "receive payment notifications" do

  let(:user) { create(:user) }

  it "should be able to do auto-clearing and complete a valid order" do

    order = user.orders.create

    Spree::BillingIntegration::Mpay.current.stub :find_order => order
    order.stub :state => 'payment'

    options = {"OPERATION"=>"CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"RESERVED", "PRICE"=>"#{(order.total.to_f*100).to_i}", "CURRENCY"=>"EUR", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}
    spree_get :show, options
    response.should be_success

    options["STATUS"] = "BILLED"
    spree_get :show, options
    response.should be_success

    closed_order = Spree::Order.find(order.id)
    closed_order.state.should == "complete"
    #closed_order.payment_state.should == "paid"
  end

  it "should throw an exception if the order is in the wrong state" do

    order = user.orders.create

    Spree::BillingIntegration::Mpay.current.stub :find_order => order
    order.stub :state => 'cart'

    options = {"OPERATION"=>"CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"RESERVED", "PRICE"=>"2529", "CURRENCY"=>"EUR", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}

    lambda do
      spree_get :show, options
    end.should raise_error

    closed_order = Spree::Order.find(order.id)
    closed_order.state.should == order.state
  end

  it "should return an error if there's the wrong currency" do

    order = user.orders.create

    Spree::BillingIntegration::Mpay.current.stub :find_order => order
    order.stub :state => 'payment'

    options = {"OPERATION"=>"CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"BILLED", "PRICE"=>"2529", "CURRENCY"=>"USD", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}

    lambda do
      spree_get :show, options
    end.should raise_error
  end

  it "should not set the state to complete if the order was underpayed" do
    order = user.orders.create

    Spree::BillingIntegration::Mpay.current.stub :find_order => order
    order.stub :state => 'payment'

    options = {"OPERATION"=>"CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"BILLED", "PRICE"=>"5", "CURRENCY"=>"EUR", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}

    spree_get :show, options

    closed_order = Spree::Order.find(order.id)
    closed_order.payment_state.should == "balance_due"
    # closed_order.state.should_not == "complete"
  end

  it "should not accept order states != RESERVED/BILLED" do
    order = user.orders.create

    Spree::BillingIntegration::Mpay.current.stub :find_order => order
    order.stub :state => 'payment'

    options = {"OPERATION"=>"CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"SOMEWRONGSTATE", "PRICE"=>"5", "CURRENCY"=>"EUR", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}

    lambda do
      spree_get :show, options
    end.should raise_error
  end

  it "should not accept operation != CONFIRMATION" do
    order = user.orders.create

    Spree::BillingIntegration::Mpay.current.stub :find_order => order
    order.stub :state => 'payment'

    options = {"OPERATION"=>"INVALID_CONFIRMATION", "TID"=>"assdf_#{order.id}", "STATUS"=>"RESERVED", "PRICE"=>"5", "CURRENCY"=>"EUR", "P_TYPE"=>"CC", "BRAND"=>"VISA", "MPAYTID"=>"1385651", "USER_FIELD"=>"", "ORDERDESC"=>order.number, "CUSTOMER"=>"Andreas Happe", "CUSTOMER_EMAIL"=>order.user.email, "LANGUAGE"=>"DE", "CUSTOMER_ID"=>"", "PROFILE_STATUS"=>"IGNORED", "FILTER_STATUS"=>"", "APPR_CODE"=>"-test-"}

    lambda do
      spree_get :show, options
    end.should raise_error
  end
end
