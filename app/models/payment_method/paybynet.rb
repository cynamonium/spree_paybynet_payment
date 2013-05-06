class PaymentMethod::Paybynet < Spree::PaymentMethod
  attr_accessible :preferred_id_client, :preferred_account, :preferred_currency, :preferred_accname 

  #paybynet settings

  preference :id_client, :string
  preference :account, :string
  preference :currency, :string, :default => "PLN"
  preference :accname, :string



  def payment_profiles_supported?
    false
  end

end
