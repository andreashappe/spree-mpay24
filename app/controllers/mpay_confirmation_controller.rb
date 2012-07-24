class MpayConfirmationController < Spree::BaseController

  # possible transaction states
  TRANSACTION_STATES = ["ERROR", "RESERVED", "BILLED", "REVERSED", "CREDITED", "SUSPENDED"]

  MPAY24_IP = "213.164.25.245"
  MPAY24_TEST_IP = "213.164.23.169"

  before_filter :verify_ip, :only => :show

  # Confirmation interface is a GET request
  def show
    check_operation(params["OPERATION"])
    check_status(params["STATUS"])

    # get the order
    order = Spree::BillingIntegration::Mpay.current.find_order(params["TID"])
    raise "Order #{params["TID"]} not found" if order.nil?
    raise "Order #{order.id} in wrong state #{order.state}" if !order.payment?

    case params["STATUS"]
    when "BILLED"
      # check if the retrieved order is the same as the outgoing one
      if verify_currency(order, params["CURRENCY"])

        payment_method = Spree::PaymentMethod.where(:type => "Spree::BillingIntegration::Mpay").where(:environment => Rails.env.to_s).first

        payment = order.payments.new
        payment.amount = params["PRICE"]
        payment.payment_method = payment_method
        payment.save!

        payment.started_processing!
        payment.complete!
        payment.save!

        order.update!
        order.next!
      else
        raise "Order #{order.id}: unknown currency #{params["CURRENCY"]}"
      end
    when "RESERVED"
	logger.info "we have auto-completion for confirmation requests, so do nothing"
    else
      raise "what is going on?".inspect
    end

    render :text => "OK", :status => 200
  end

  private

  def check_operation(operation)
    if operation != "CONFIRMATION"
      raise "unknown operation: #{operation}".inspect
    end
  end

  def check_status(status)
    if !TRANSACTION_STATES.include?(status)
      raise "unknown status: #{status}".inspect
    end
  end

  def verify_currency(order, currency)
    "EUR" == currency
  end

  def verify_ip
    return if Rails.env.test?

    remote_ip = request.env['REMOTE_ADDR']
    if remote_ip == "127.0.0.1"
      #maybe we've gotten forwarded by the nginx reverse proxy
      if request.env.include?('HTTP_X_FORWARDED_FOR')
        ips = request.env['HTTP_X_FORWARDED_FOR'].split(',').map(&:strip)
        remote_ip = ips[1]
      else
        raise request.env.inspect
      end
    end

    if ![MPAY24_IP, MPAY24_TEST_IP].include?(remote_ip)
      raise "invalid originator IP of '#{remote_ip}'".inspect
    end
  end
end
