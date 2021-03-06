# -*- encoding : utf-8 -*-
#!/bin/env ruby
# encoding: utf-8
require 'digest/sha1'

class Gateway::PaybynetController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:comeback, :complete]

  # Show form Dotpay for pay
  def show
    if session[:idbank]
      @idbank = session[:idbank]
      session[:idbank] = nil
    end
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

  def notify

  end

  def complete
    @order = Spree::Order.find(session[:order_id])
    session[:order_id] = nil
    @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)
    redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token}), :notice => "Paybynet correct"
  end

  def reject
    @order = Spree::Order.find(session[:order_id])
    redirect_to order_url(@order, {:checkout_complete => true}), :notice => "Paybynet not correct"
  end

  def comeback
    newStatus = params[:newStatus] #status transakcji
    transAmount = params[:transAmount]
    paymentId = params[:paymentId] #identyfikator transakcji przekazane ze sklepu.
    hash = params[:hash] #skrót SHA1 z połączenia : newStatus + transAmount + paymentId + password

    @order = Spree::Order.find_by_number(paymentId)
    gateway = @order && @order.payments.first.payment_method

    check = Digest::SHA1.hexdigest(newStatus + transAmount + paymentId + gateway.preferred_password)

    if check==hash
      if newStatus=='2203' || newStatus=='2303'
          paybynet_payment_success(transAmount.to_f,@order)
          render :text => "OK", :layout => false
      elsif newStatus=='2202' || newStatus=='2302'
          paybynet_payment_fail(params,@order)
          render :text => "OK", :layout => false
      else
          render :text => "OK", :layout => false
      end
    else
      render :text => "FAIL", :layout => false
    end
  end


  def hashtrans(order, gateway)
    time = Time.new + 3.days

    xml = "<id_client>"+gateway.preferred_id_client+"</id_client>"
    xml += "<id_trans>"+order.number+"</id_trans>"
    xml += "<date_valid>"+time.strftime("%d-%m-%Y %H:%M:%S")+"</date_valid>" 
    xml += "<amount>"+order.total.to_s.sub!(".", ",")+"</amount><currency>PLN</currency>"
    xml += "<email>"+order.user.try(:email)+"</email>"
    xml += "<account>"+gateway.preferred_account+"</account>"
    xml += "<accname>"+gateway.preferred_accname+"^NM^"+gateway.preferred_postcode+"^ZP^"+gateway.preferred_city+"^CI^"+gateway.preferred_street+"^ST^"+gateway.preferred_country+"^CT^</accname>"
    xml += "<backpage>"+main_app.gateway_paybynet_complete_url(@order.number)+"</backpage>"
    xml += "<backpagereject>"+main_app.gateway_paybynet_reject_url(@order.number)+"</backpagereject>"

    hash = Digest::SHA1.hexdigest(xml + "<password>"+gateway.preferred_password+"</password>")

    xml += "<hash>"+hash+"</hash>"

    @xm = xml

    ActiveSupport::Base64.encode64(xml)

  end

  private

  # Completed payment process
  def paybynet_payment_success(price, order)
      sleep(10)
    if order.payment_state != 'paid'
      order.payments.first.started_processing!
      cash = order.payments.first
      cash.amount = price
      cash.save
      order.payments.first.complete
      order.payment_state = 'paid'

      order.finalize!
      order.next
      order.next
      order.save
    end
  end

  def paybynet_payment_fail(params, order)
      order.payments.first.complete
      order.payment_state = 'fail'
      order.save
  end



end


