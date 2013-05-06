Rails.application.routes.draw do
  # Add your extension routes here
  namespace :gateway do
    match '/paybynet/:gateway_id/:order_id' => 'paybynet#show', :as => :paybynet
    match '/paybynet/comeback/' => 'paybynet#comeback', :as => :paybynet_comeback
    match '/paybynet/complete' => 'paybynet#complete', :as => :paybynet_complete
  end
end
