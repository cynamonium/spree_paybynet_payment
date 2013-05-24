Rails.application.routes.draw do
  # Add your extension routes here
  namespace :gateway do
    match '/paybynet/:gateway_id/:order_id' => 'paybynet#show', :as => :paybynet
    match '/paybynet/comeback/' => 'paybynet#comeback', :as => :paybynet_comeback, :via => [:get, :post]
    match '/paybynet/complete' => 'paybynet#complete', :as => :paybynet_complete
    match '/paybynet/reject' => 'paybynet#reject', :as => :paybynet_reject
    match '/paybynet/notify' => 'paybynet#notify', :as => :paybynet_notify
  end
end
