module SpreeMultiDomain
  class Engine < Rails::Engine
    engine_name 'spree_multi_domain'

    config.autoload_paths += %W(#{config.root}/lib)

    config.to_prepare do
      ['app', 'lib'].each do |dir|
        Dir.glob(File.join(File.dirname(__FILE__), "../../#{dir}/**/*_decorator*.rb")) do |c|
          Rails.application.config.cache_classes ? require(c) : load(c)
        end
      end

      Spree::Config.searcher_class = Spree::Search::MultiDomain
      ApplicationController.send :include, SpreeMultiDomain::MultiDomainHelpers
    end

    initializer "templates with dynamic layouts" do
      ActiveSupport.on_load(:action_view) do
        ActionView::TemplateRenderer.class_eval do
          def find_layout_with_multi_store(layout, locals)
            store_layout = layout

            if @view.respond_to?(:current_store) && @view.current_store && !@view.controller.is_a?(Spree::Admin::BaseController)
              store_layout = if layout.is_a?(String)
                               layout.gsub("layouts/", "layouts/#{@view.current_store.code}/")
                             else
                               layout.call.try(:gsub, "layouts/", "layouts/#{@view.current_store.code}/")
                             end
            end

            begin
              find_layout_without_multi_store(store_layout, locals)
            rescue ::ActionView::MissingTemplate
              find_layout_without_multi_store(layout, locals)
            end
          end

          alias_method :find_layout_without_multi_store, :find_layout
          alias_method :find_layout, :find_layout_with_multi_store
        end
      end
    end

    initializer "current order decoration" do
      ActiveSupport.on_load(:action_controller) do
        require 'spree/core/controller_helpers/order'
        ::Spree::Core::ControllerHelpers::Order.module_eval do
          def current_order_with_multi_domain(options = {})
            options[:create_order_if_necessary] ||= false
            current_order_without_multi_domain(options)

            if @current_order && current_store && @current_order.store.blank?
              @current_order.update_attribute(:store_id, current_store.id)
            end

            @current_order
          end

          alias_method :current_order_without_multi_domain, :current_order
          alias_method :current_order, :current_order_with_multi_domain
        end
      end
    end

    initializer 'spree.promo.register.promotions.rules' do |app|
      app.config.spree.promotions.rules << Spree::Promotion::Rules::Store
    end
  end
end
