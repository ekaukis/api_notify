require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'active_support/deprecation/reporting'
require "api_notify/active_record/synchronizer"

module ApiNotify
  module ActiveRecord
    module Main
      extend ActiveSupport::Concern

      METHODS = %w[post get delete put]

      module ClassMethods
        def api_notify(fields, identificators, *args)
          options = args.extract_options!

          after_update :post_via_api
          after_create :post_via_api
          after_destroy :delete_via_api
          before_update :post_gather_changes
          before_create :post_gather_changes
          before_destroy :delete_gather_changes

          attr_accessor :skip_api_notify, :attributes_changed

          define_method :notify_attributes do
            fields
          end

          define_method :identificators do
            identificators
          end

          METHODS.each do |method|
            define_method "api_notify_#{method}_success" do |response|
            end

            define_method "api_notify_#{method}_failed" do |response|
            end
          end

          options.each_pair do |key, value|
            define_singleton_method key do
              value
            end
          end

          define_singleton_method :route_name do
            begin
              return api_route_name.downcase
            rescue Exception => e
              _name = defined?(class_name) ? class_name : name
              return _name.pluralize.downcase
            end
          end

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


      # Check if any watched attribute changed
      # Unless any attribute changed than dont send any request
      # if is_synchronized defined than check if its true, unless its true synchronize it

      def must_sync
        _must_sync = false
        _must_sync = !send(self.class.is_synchronized) if defined? self.class.is_synchronized
        _must_sync
      end

      def no_need_to_synchronize?(method)
        if defined? self.class.skip_synchronize
          return true if send(self.class.skip_synchronize)
        end

        if method != "delete" && attributes_changed.empty?
          return true
        end

        false
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

      def set_attributes_changed
        @attributes_changed = attributes_as_params
      end

      def method_missing(m, *args)
        vars = m.to_s.split(/_/, 2)
        if METHODS.include?(vars.first) && vars.last == "via_api"
          return unless ApiNotify.configuration.active
          return if skip_api_notify || no_need_to_synchronize?(vars.first)
          synchronizer = self.class.synchronizer
          synchronizer.set_params(attributes_changed.merge(get_identificators))
          synchronizer.send_request(vars.first.upcase)

          disable_api_notify

          if synchronizer.success?
            send("api_notify_#{vars.first}_success", synchronizer.response)
          else
            send("api_notify_#{vars.first}_failed", synchronizer.response)
          end

          enable_api_notify
        elsif METHODS.include?(vars.first) && vars.last == "gather_changes"
          set_attributes_changed
        else
          super
        end
      end
    end
  end
end
