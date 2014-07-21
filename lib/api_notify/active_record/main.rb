require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'active_support/deprecation/reporting'
require "api_notify/active_record/synchronizer"
require "api_notify/workers/synchronizer_worker"

module ApiNotify
  module ActiveRecord
    module Main
      extend ActiveSupport::Concern

      METHODS = %w[post get delete put]

      module ClassMethods
        def api_notify(fields, identificators, endpoints, *args)
          attr_accessor :skip_api_notify

          assign_callbacks
          assign_associations

          define_method :notify_attributes do
            fields
          end

          define_method :identificators do
            identificators
          end

          define_method :endpoints do
            endpoints
          end

          endpoints.each_pair do |endpoint, params|
            define_default_request_callbacks endpoint
            define_options params, endpoint
          end
          define_options args.extract_options!

          define_route_name
          define_synchronizer identificators

          def unsynchronized(endpoint)
            relation = joins("LEFT JOIN `api_notify_logs` ON api_notify_logs.api_notify_logable_id = #{self.table_name}.id AND api_notify_logable_type = '#{self.name}' AND api_notify_logs.endpoint='#{endpoint}'").where("api_notify_logs.api_notify_logable_id IS NULL")

            if methods.include?("#{endpoint}_scope".to_sym)
              relation = relation.send(send("#{endpoint}_scope"))
            end

            relation
          end
        end

        def assign_callbacks
          after_update :post_via_api
          after_create :post_via_api
          after_destroy :delete_via_api
          before_update :post_gather_changes
          before_create :post_gather_changes
          before_destroy :delete_gather_changes
        end

        def assign_associations
          has_many :api_notify_logs, as: :api_notify_logable, dependent: :destroy, class_name: ApiNotify::Log
          has_many :api_notify_tasks, as: :api_notifiable, class_name: ApiNotify::Task
        end

        # Defines default callback methods, like success and failed for each endpoint
        def define_default_request_callbacks endpoint
          METHODS.each do |method|
            define_method "#{endpoint}_api_notify_#{method}_success" do |response|
            end

            define_method "#{endpoint}_api_notify_#{method}_failed" do |response|
            end
          end
        end

        # If endpoint given, defined mehod will be assigned to endpoint
        def define_options options, endpoint = false
          options.each_pair do |key, value|
            method_name = endpoint ? "#{endpoint}_#{key}" : key
            define_singleton_method method_name do
              value
            end unless method_defined? method_name.to_sym
          end
        end

        # Route name will be used to create url for request
        def define_route_name
          define_singleton_method :route_name do
            begin
              return api_route_name.downcase
            rescue Exception => e
              _name = defined?(class_name) ? class_name : name
              return _name.pluralize.downcase
            end
          end
        end

        def define_synchronizer identificators
          define_singleton_method :synchronizer do
            ActiveRecord::Synchronizer.new route_name, identificators.keys.first
          end
        end
      end

      ##
      # Helper methods for activrecord instance
      ##
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

      def destroy_without_api_notify *args
        self.disable_api_notify if defined? self.skip_api_notify
        self.destroy *args
      end

      def api_notified? endpoint
        api_notify_logs.find_by(endpoint: endpoint).present?
      end

      def make_api_notified endpoint
        api_notify_logs.find_or_initialize_by(endpoint: endpoint).save
      end

      def remove_api_notified endpoint
        api_notify_logs.find_by(endpoint: endpoint).try(:destroy)
      end

      def notify_children endpoint
        if self.class.methods.include?("#{endpoint}_children".to_sym)
          self.class.send("#{endpoint}_children").each do |child_class|
            self.send(child_class).unsynchronized(endpoint).each do |resource|
              resource.make_api_notify_call(endpoint)
              LOGGER.info "NOTIFY CHILD: Parent: #{self.class.name}-#{self.id} Child: #{resource.class.name}-#{resource.id}"
            end
          end
        end
      end
      ##
      # If @must_sync == true then forces all attributes to be synchronized
      ##
      def fields_to_change endpoint
        @must_sync = !api_notified?(endpoint)
        notify_attributes.inject([]) do |_fields, field|
          if field_changed?(field) || @must_sync
            _fields << field
          end
          _fields
        end
      end

      def fill_fields_with_values fields
        fields.inject({}){ |_fields, field| _fields[field] = get_value(field);  _fields }
      end

      def get_identificators(endpoint)
        if self.class.methods.include?("#{endpoint}_identificators".to_sym)
          additional = self.class.send("#{endpoint}_identificators")
        else
          additional = {}
        end

        identificators.merge(additional).inject({}){ |hash, (key, value)| hash[key] = get_value(value); hash}
      end

      def all_indentificators?(endpoint)
        return true unless self.class.methods.include?("#{endpoint}_parent_attribute".to_sym)
        return get_identificators(endpoint)[self.class.send("#{endpoint}_parent_attribute")].present?
      end

      def parent_api_notified_or_notify_it?(endpoint)
        if self.class.methods.include?("#{endpoint}_force_parent_sync".to_sym)
          unless self.send(self.class.send("#{endpoint}_force_parent_sync")).api_notified?(endpoint)
            self.send(self.class.send("#{endpoint}_force_parent_sync".to_sym)).make_api_notify_call(endpoint)
            return false
          end
        end

        true
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

      def set_fields_changed
        @fields_changed = endpoints.inject({}){|r, (endpoint, p)| r[endpoint] = fields_to_change(endpoint); r }
      end

      def fields_changed(endpoint)
        @fields_changed.is_a?(Hash) ? @fields_changed[endpoint.to_sym] : []
      end

      # Create task only if all identificators given, else task will be created after parent object creates it
      def create_task(endpoint, method)
        return if no_need_to_synchronize?(method, endpoint) || !all_indentificators?(endpoint) || !parent_api_notified_or_notify_it?(endpoint)

        LOGGER.info "BEGIN TASK CREATING"
        task = Task.create({
          api_notifiable: self,
          fields_updated: fields_changed(endpoint),
          identificators: get_identificators(endpoint),
          endpoint: endpoint,
          method: method
        })
      end

      def make_api_notify_call(endpoint)
        post_gather_changes
        create_task endpoint, "post"
      end

      def no_need_to_synchronize?(method, endpoint)
        return true unless ApiNotify.configuration.config_defined?
        return true unless ApiNotify.configuration.endpoint_active?(endpoint)
        return true if skip_api_notify

        if self.class.methods.include? "#{endpoint}_skip_synchronize".to_sym
          return true if send self.class.send("#{endpoint}_skip_synchronize")
        end

        if method != "delete" && fields_changed(endpoint).empty?
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
            endpoints.each_pair do |endpoint, params|
              create_task endpoint, vars.first
            end
          when "gather_changes"
            set_fields_changed
          end
        else
          super
        end
      end
    end
  end
end
