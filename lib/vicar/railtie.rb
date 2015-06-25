require 'rails/railtie'

module Vicar
  class Railtie < Rails::Railtie
    initializer 'vicar.rails_extensions' do |app|
      ActiveSupport.on_load(:action_view) do
        include Vicar::RailsExtensions::ActionView
      end
    end
    
    def prepare_products_loader
      loader.
        select('*, (price * currency_rate) converted_price').
        order_products_by(order_conditions).
        order_premium_products_in_groups(order_conditions_in_groups).
        load_sphinx_attributes(:product_groups)
  
      loader.load_statistics_by_words_if_empty if search?   # загружать статистику по словам для пустого поиска
  
      if default_listing_sort?
        if boost_by_region?
          loader.boost_by_region(current_region_by_ip_or_default, :with_native_regions => true) if current_region.default?
          loader.boost_by_region(current_region) unless current_region.default?
        end
  
        loader.with_regional_packet_sort(current_region) if use_virtual_packet_sort?
      end
    end
  end
end
