module ApiNotify
  module ActiveRecord
    class Synchronizer

      class FailedSynchronization < StandardError; end

      require "net/http"
      require 'net/https'

      def initialize(route_name, id_param)
        @_params = {}
        @route_name = route_name
        @id_param = id_param
      end

      def response
        {
          status: @_response.code,
          body: JSON.parse(@_response.body)
        }
      rescue JSON::ParserError => e
        {
          status: e.class.name,
          body: e.message.truncate(1000, separator: "\n")
        }
      rescue NoMethodError => e
        {
          status: e.class.name,
          body: @_response[:error].message
        }
      end

      def success?
        %w(200 201 202 203 204).include?(response[:status].to_s)
      end

      def request_id
        @request_id ||= "ReQ#{ Time.current.to_i }#{ SecureRandom.urlsafe_base64(9) }"
      end

      def send_request(type = 'GET', url_param = false, endpoint)
        unless ApiNotify.configuration.config_defined?
          raise FailedSynchronization.new("missing configuration")
        end

        @config = ApiNotify.configuration.config(endpoint)
        begin
          http = Net::HTTP.new(@config["domain"], @config["port"])
          if @config["port"].to_i == 443
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          _url = url_param ? build_url(url_param) : url(type)
          LOGGER.info(
            "#{ request_id } Response #{ @config["domain"] }:"\
            "#{ @config["port"] }#{ _url }?#{ params_query }"
          )
          @_response = http.send_request(type, _url, params_query, headers)
        rescue Exception => e
          @_response = {error: e}
        end

        log_response
        response
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
        self
      end

      private
        def log_response
          LOGGER.info(
            "#{ request_id } Response #{ response[:status] }: "\
            "#{ response[:body].to_s.truncate(1000, separator: "\n") }\n"
          )
        end
    end
  end
end
