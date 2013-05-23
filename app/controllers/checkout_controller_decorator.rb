Spree::CheckoutController.class_eval do

  before_filter :redirect_for_paybynet, :only => :update

  private

  def redirect_for_paybynet
    return unless params[:state] == "payment"
    @payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    if @payment_method && @payment_method.kind_of?(PaymentMethod::Paybynet)
      redirect_to main_app.gateway_paybynet_path(@idbank => params[:idbank], :gateway_id => @payment_method.id, :order_id => @order.id)
    end
  end

end
