module ApiNotify
  module ActiveRecord
    class Synchronizer
      require "net/http"
      require 'net/https'

      def initialize route_name, id_param
        @config = load_config_yaml
        @_params = {}
        @route_name = route_name
        @_success = false
        @id_param = id_param
      end

      def response
        begin
          { status: @_response.code, body: JSON.parse(@_response.body)}
        rescue JSON::ParserError, NoMethodError => e
          case e.class.name
          when "NoMethodError"
            { status: e.class.name, body: "#{e.message} | #{@_response[:error].message}" }
          when "JSON::ParserError"
            { status: e.class.name, body: "#{e.message} | #{@_response.body}" }
          end
        end
      end

      def success?
        @_success
      end

      def send_request(type = 'GET', url_param = false)
        begin
          http = Net::HTTP.new(@config["domain"], @config["port"])
          if @config["port"].to_i == 443
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          _url = url_param ? build_url(url_param) : url(type)
          ApiNotify::LOGGER.info "Request #{@config["domain"]}:#{@config["port"]}#{_url}?#{params_query}"
          @_response = http.send_request(type, _url, params_query, headers)
          @_success = true
        rescue Exception => e
          @_response = {error: e}
        end
        log_response
        @_response
      end

      def params_query
        @_params.empty? ? "" : "#{@_params.to_query}"
      end

      def headers
        headers = {
          "Content-type" => "application/x-www-form-urlencoded",
          "Content-Length" => params_query.length.to_s,
          "Api-Key" => @config["api_key"].to_s
        }
      end

      def url type
        id = @_params[@id_param] && type!= "POST" ? "#{@_params[@id_param]}" : nil
        build_url id
      end

      def build_url param
        _url = param ? "/#{param}" : ""
        "#{@config["base_path"]}/#{@route_name}#{_url}"
      end

      def set_params params
        @_params = params
      end

      private
        def load_config_yaml
          config_yaml = "#{Rails.root.to_s}/config/api_notify.yml"
          YAML.load_file(config_yaml)[Rails.env] if File.exists?(config_yaml)
        end

        def log_response
          if %w(500 501 502 503 504 505 506).include? response[:status]
            ApiNotify::LOGGER.info "Response #{response[:status]}: #{ response[:body].truncate(1000, separator: "\n") if response[:body].present?}\n"
          else
            ApiNotify::LOGGER.info "Response #{response[:status]}: #{ response[:body] }\n"
          end
        end
    end
  end
end
