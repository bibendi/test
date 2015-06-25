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
    
    def predl_cache_key
      {
        :section => 'catalogue:predl',
        :region => current_region.name_lat,
        :region_by_ip => current_region_by_ip.try(:name_lat),
        :rubric => rubric.id,
        :facets => traits_filter_to_json,
        :search => search?,
        :favorite => filtered_by_favorites? ? "#{current_user.try(:id)}:#{cookies[UserFavoriteCompany::COOKIES_SID_KEY]}" : nil,
        :q => search_query,
        :super_user => super_user?,
        :signed_in => signed_in?,
        :listing_sort => listing_sort || 'default',
        :listing_style => listing_style,
        :company_id => @company.try(:id),
        :is_ajax => request.xhr?,
        :page => params[:page],
        :showpp => params[:showpp],
        :mobile_device => mobile_device?
      }
    end
    
  end
end
