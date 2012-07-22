#require File.dirname(__FILE__) + '/../spec_helper'

require 'spec_helper'

describe MpayConfirmationController, "receive notifications" do
  it "should be able to receive a notificaiton" do
    get :show
  end
end
