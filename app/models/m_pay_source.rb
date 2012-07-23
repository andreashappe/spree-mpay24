class MPaySource < ActiveRecord::Base
  belongs_to :payment

  validates_presence_of :p_type, :mpayid

  attr_accessible :p_type, :brand, :mpayid

  def payment_gateway
     BillingIntegration::Mpay.current
  end
end
