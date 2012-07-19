class MpayConfirmationController < Spree::BaseController

  # possible transaction states
  TRANSACTION_STATES = ["ERROR", "RESERVED", "BILLED", "REVERSED", "CREDITED", "SUSPENDED"]

  MPAY24_IP = "213.164.25.245"
  MPAY24_TEST_IP = "213.164.23.169"

  # Confirmation interface is a GET request
  def show

    verify_ip(request)

    check_operation(params["OPERATION"])
    check_status(params["STATUS"])

    # get the order
    order = BillingIntegration::Mpay.current.find_order(params["TID"])

    case params["STATUS"]
    when "BILLED"
      # check if the retrieved order is the same as the outgoing one
      if verify_currency(order, params["CURRENCY"])

        # create new payment object
        payment_details = MPaySource.create ({
          :p_type => params["P_TYPE"],
          :brand => params["BRAND"],
          :mpayid => params["MPAYTID"]
	})

        payment_details.save!

        payment_method = PaymentMethod.where(:type => "BillingIntegration::Mpay").where(:environment => RAILS_ENV.to_s).first

        # TODO log the payment
        payment = order.payments.create({
          :amount => params["PRICE"],
          :payment_method_id => payment_method,
          :source => payment_details
	})

        # TODO: create this before (when sending the request?)
	# TODO: but do we even want this?
        payment.started_processing!
        payment.complete!
        payment.save!

        payment_details.payment = payment
        payment_details.save!
        order.update!
        order.next!
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

  def find_order(tid)
    if (order = Order.find(tid)).nil?
      raise "could not find order: #{tid}".inspect
    end

    return order
  end

  def verify_currency(order, currency)
    "EUR" == currency
  end

  def verify_ip(request)
    if [MPAY24_IP, MPAY24_TEST_IP].include?(request.env['REMOTE_ADDR'])
      if request.env['REMOTE_ADDR'] == "127.0.0.1"
        #maybe we've gotten forwarded by the nginx reverse proxy
	if request.env.include?('HTTP_X_FORWARDED_FOR')
          ips = request.env['HTTP_X_FORWARDED_FOR'].split(',').map(&:strip)
          if ips[1] != mpay24_ip
            raise "invalid forwarded originator IP of x#{ips[1]}x vs #{mpay24_ip}".inspect
          end 
        else
          raise request.env.inspect
        end
      else
        raise "invalid originator IP of #{request.env['REMOTE_ADDR']} vs #{mpay24_ip}".inspect
      end
    end
  end

end
