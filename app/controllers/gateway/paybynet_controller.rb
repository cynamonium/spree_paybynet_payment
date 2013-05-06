require 'digest/sha1'
require 'base64'

class Gateway::PaybynetController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:comeback, :complete]

  # Show form Dotpay for pay
  def show
    @order = Spree::Order.find(params[:order_id])
    @gateway = @order.available_payment_methods.find{|x| x.id == params[:gateway_id].to_i }
    @order.payments.destroy_all
    payment = @order.payments.create!(:amount => 0, :payment_method_id => @gateway.id)

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("invalid_arguments")
      redirect_to :back
    else
      @bill_address, @ship_address = @order.bill_address, (@order.ship_address || @order.bill_address)
    end
    @hashtrans = hashtrans(@order, @gateway)
    render(:layout => false)
  end

  
  def complete
    @order = Spree::Order.find(session[:order_id])
    session[:order_id] = nil
     @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)
    redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token}), :notice => "Dotpay correct"
  end

  def reject_url
  end


  private

  def hashtrans(order, gateway)
    time = Time.new

    xml = "<id_client>"+gateway.preferred_id_client+"</id_client>"
    xml << "<id_trans>"+order.number+"</id_trans>"
    xml << "<date_valid>"+time.strftime("%Y-%m-%d %H:%M:%S")+"</date_valid>" 
    xml << "<amount>"+order.total.to_s.sub!(".", ",")+"</amount><currency>PLN</currency>"
    xml << "<email>"+order.user.try(:email)+"</email>"
    xml << "<account>"+gateway.preferred_account+"</account>"
    xml << "<accname>"+gateway.preferred_accname+"</accname>"
    xml << "<backpage>"+main_app.gateway_paybynet_complete_url(@order.number)+"</backpage>"
    xml << "<backpagereject>"+main_app.gateway_paybynet_reject_url(@order.number)+"</backpagereject>"

    hash = Digest::SHA1.hexdigest(xml + "<password>"+gateway.preferred_password+"</password>")

    xml << "<hash>"+hash+"</hash>"

    Base64.encode64(xml)

  end

  # validating dotpay message
  def paybynet_validate(gateway, params, remote_ip)
    calc_md5 = Digest::MD5.hexdigest(@gateway.preferred_pin + ":" +
      (params[:id].nil? ? "" : params[:id]) + ":" +
      (params[:control].nil? ? "" : params[:control]) + ":" +
      (params[:t_id].nil? ? "" : params[:t_id]) + ":" +
      (params[:amount].nil? ? "" : params[:amount]) + ":" +
      (params[:email].nil? ? "" : params[:email]) + ":" +
      (params[:service].nil? ? "" : params[:service]) + ":" +
      (params[:code].nil? ? "" : params[:code]) + ":" +
      ":" +
      ":" +
      (params[:t_status].nil? ? "" : params[:t_status]))
      md5_valid = (calc_md5 == params[:md5])

      if (remote_ip == @gateway.preferred_dotpay_server_1 || remote_ip == @gateway.preferred_dotpay_server_2) && md5_valid
        valid = true #yes, it is
      else
       valid = false #no, it isn't
      end
      valid
  end

  # Completed payment process
  def paybynet_payment_success(params)
    @order.payment.started_processing
    if @order.total.to_f == params[:amount].to_f
      @order.payment.complete
    end

    @order.finalize!

    @order.next
    @order.next
    @order.save
  end

  # payment cancelled by user (dotpay signals 3 to 5)
  def paybynet_payment_cancel(params)
    @order.cancel
  end

  def paybynet_payment_new(params)
    @order.payment.started_processing
    @order.finalize!
  end

end


