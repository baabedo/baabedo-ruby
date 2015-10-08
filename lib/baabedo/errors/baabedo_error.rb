module Baabedo
  class BaabedoError < StandardError
    attr_reader :message
    attr_reader :http_status
    attr_reader :http_body
    attr_reader :json_body

    def initialize(message=nil, http_status=nil, http_body=nil, json_body=nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @json_body = json_body
    end

    def request_id
      @json_body[:id]
    rescue
      nil
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      id_string = "; Request-Id: #{request_id}" unless request_id.nil?
      "#{status_string}#{@message}#{id_string}"
    end
  end
end
