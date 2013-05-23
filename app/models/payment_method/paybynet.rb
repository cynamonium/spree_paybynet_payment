class PaymentMethod::Paybynet < Spree::PaymentMethod
  attr_accessible :preferred_country, :preferred_street, :preferred_city, :preferred_postcode, :preferred_id_client, :preferred_url, :preferred_password, :preferred_account, :preferred_currency, :preferred_accname 

  #paybynet settings

  preference :id_client, :string
  preference :account, :string
  preference :currency, :string, :default => "PLN"
  preference :accname, :string
  preference :url, :string, :default => "https://pbn.paybynet.com.pl/PayByNetT/trans.do"
  preference :password, :string 
  preference :postcode, :string
  preference :city, :string
  preference :street, :string
  preference :country, :string



  def payment_profiles_supported?
    false
  end

end
