require 'delegate'

module Vicar
  class BasePresenter < SimpleDelegator
    def complex_meth
      if 1 == 2 && 2 == 1 && 3 == 4 && 4 == 7
        puts 1
      end
      
      if 1 == 2 && 2 == 1 && 3 == 4 && 4 == 6
        puts 1
      end
      if 1 == 2 && 2 == 1 && 3 == 4 && 4 == 7
        puts 1
      end
      if 1 == 2 && 2 == 1 && 3 == 4 && 4 == 7
        puts 1
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
  
      if group_by_company?
        loader.load_premium_products(:limit => CatalogueController::PRODUCTS_LIMIT) do |loader|
          if switch_to_short_listing_mode?(loader.results)
            @load_short_listing = true
            @group_by_company = false
            false # загружаем без премиальных товаров
          else
            true # загружаем с премиальными товарами
          end
        end
      else
        loader.load_products
      end
    end
  end
end
