module Zendesk
  class Error < StandardError
    attr_reader :http_headers, :status

    def initialize(message, headers, status)
      @http_headers = Hash[headers]
      @status = status
      super message
    end
  end

  class BadRequest    < Error; end
  class Unauthorized  < Error; end
  class Forbidden     < Error; end
  class NotFound      < Error; end
  class NotAcceptable < Error; end
  class Chill         < Error; end

  module Response
    class RaiseHttp4xx < Faraday::Response::Middleware
      def on_complete(env)
        case env[:status].to_i
        when 400
          raise Zendesk::BadRequest.new(error_message(env), env[:response_headers], 400)
        when 401
          raise Zendesk::Unauthorized.new(error_message(env), env[:response_headers], 401)
        when 403
          raise Zendesk::Forbidden.new(error_message(env), env[:response_headers], 403)
        when 404
          raise Zendesk::NotFound.new(error_message(env), env[:response_headers], 404)
        when 406
          raise Zendesk::NotAcceptable.new(error_message(env), env[:response_headers], 406)
        when 420
          raise Zendesk::Chill.new(error_message(env), env[:response_headers], 420)
        end
      end

      private ###################################################

      def error_message(env)
        "#{error_body(env[:body])} [#{env[:method].to_s.upcase} #{env[:url]} :: #{env[:status]}]"
      end

      def error_body(body)
        if body.nil?
          "<No error message>"
        elsif body.is_a? Hashie::Mash
          if body["error"].is_a? Hashie::Mash
            "#{body["error"].title} #{body['error'].message}"
          else
            "#{body["error"]}"
          end
        elsif body.is_a? Array
          "#{body.join(' ')}"
        elsif body["errors"]
          first = body["error"][0]
          if first.kind_of? Hash
            "#{first["message"].chomp}"
          else
            "#{first.chomp}"
          end
        end
      end
    end
  end
end
