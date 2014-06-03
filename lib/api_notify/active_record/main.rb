require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'active_support/deprecation/reporting'
require "api_notify/active_record/synchronizer"

module ApiNotify
  module ActiveRecord
    module Main
      extend ActiveSupport::Concern

      METHODS = %w[post get delete put]

      included do
        has_many :api_notify_tasks, as: :api_notify_logable
        has_many :api_notify_logs, as: :api_notifiable
      end

      module ClassMethods
        def api_notify(fields, identificators, *args)
          attr_accessor :skip_api_notify, :attributes_changed

          set_callbacks

          define_method :notify_attributes do
            fields
          end

          define_method :identificators do
            identificators
          end

          define_default_callback_methods
          define_options_methods args.extract_options!
          define_route_name_method
          define_synchronizer_method identificators
        end

        def set_callbacks
          after_update :post_via_api
          after_create :post_via_api
          after_destroy :delete_via_api
          before_update :post_gather_changes
          before_create :post_gather_changes
          before_destroy :delete_gather_changes
        end

        def define_default_callback_methods
          METHODS.each do |method|
            define_method "api_notify_#{method}_success" do |response|
            end

            define_method "api_notify_#{method}_failed" do |response|
            end
          end
        end

        def define_options_methods options
          options.each_pair do |key, value|
            define_singleton_method key do
              value
            end
          end
        end

        def define_route_name_method
          define_singleton_method :route_name do
            begin
              return api_route_name.downcase
            rescue Exception => e
              _name = defined?(class_name) ? class_name : name
              return _name.pluralize.downcase
            end
          end
        end

        def define_synchronizer_method identificators
          define_singleton_method :synchronizer do
            ApiNotify::ActiveRecord::Synchronizer.new route_name, identificators.keys.first
          end
        end

      end

      def disable_api_notify
        self.skip_api_notify = true
      end

      def enable_api_notify
        self.skip_api_notify = false
      end

      def save_without_api_notify *args
        self.disable_api_notify if defined? self.skip_api_notify
        self.save *args
      end

      def update_attributes_without_api_notify attributes
        self.disable_api_notify if defined? self.skip_api_notify
        self.update_attributes attributes
      end

      def must_sync
        _must_sync = false
        _must_sync = !send(self.class.is_synchronized) if defined? self.class.is_synchronized
        _must_sync
      end

      def attributes_as_params
        notify_attributes.inject({}) do |_fields, field|
          if field_changed?(field) || must_sync
            _fields[field] = get_value(field)
          end
          _fields
        end
      end

      def get_identificators
        _fields = {}
        identificators.each_pair { |key, value| _fields[key] = get_value(value) }
        _fields
      end

      def get_value(field)
        "#{field.to_s}".split('.').inject(self) { |obj, method| obj.present? ? obj.send(method) : "" }
      end

      def field_changed?(field)
        "#{field.to_s}_changed?".split('.').inject(self) do |obj, method|
          if obj.present?
            obj.send(method)
          else
            false
          end
        end
      end

      def synchronize method
        synchronizer = self.class.synchronizer
        synchronizer.set_params(attributes_changed.merge(get_identificators))
        synchronizer.send_request(method.upcase)

        disable_api_notify

        if synchronizer.success?
          send("api_notify_#{method}_success", synchronizer.response)
        else
          send("api_notify_#{method}_failed", synchronizer.response)
        end

        enable_api_notify
      end

      def set_attributes_changed
        @attributes_changed = attributes_as_params
      end

      def no_need_to_synchronize?(method)
        return true if skip_api_notify

        if defined? self.class.skip_synchronize
          return true if send(self.class.skip_synchronize)
        end

        if method != "delete" && attributes_changed.empty?
          return true
        end

        false
      end

      def method_missing(m, *args)
        vars = m.to_s.split(/_/, 2)
        if METHODS.include?(vars.first)
          return unless ApiNotify.configuration.active
          case vars.last
          when "via_api"
            synchronize vars.first unless no_need_to_synchronize?(vars.first)
          when "gather_changes"
            set_attributes_changed
          end
        else
          super
        end
      end
    end
  end
end
