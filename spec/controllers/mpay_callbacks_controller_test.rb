#require File.dirname(__FILE__) + '/../spec_helper'

require 'spec_helper'

describe MpayCallbacksController, "some callback thing" do
  it "should be able to display a status message" do
    get :index
  end
end
