require 'spree_core'

module SpreePaybynetPayment
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << PaymentMethod::Paybynet
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
