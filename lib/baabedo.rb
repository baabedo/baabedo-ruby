require 'cgi'
require 'openssl'
require 'rbconfig'
require 'set'
require 'socket'

require 'rest-client'
require 'json'

require "baabedo/version"

# Operations
require 'baabedo/api_operations/create'
require 'baabedo/api_operations/update'
require 'baabedo/api_operations/delete'
require 'baabedo/api_operations/list'
require 'baabedo/api_operations/request'
# Resources
require 'baabedo/util'
require 'baabedo/api_object'
require 'baabedo/api_resource'
require 'baabedo/list_object'

require 'baabedo/company'

# Errors
require 'baabedo/errors/baabedo_error'
require 'baabedo/errors/api_error'
require 'baabedo/errors/api_connection_error'
require 'baabedo/errors/invalid_request_error'
require 'baabedo/errors/authentication_error'

require 'baabedo/client'

module Baabedo
  DEFAULT_CA_BUNDLE_PATH = File.dirname(__FILE__) + '/data/ca-certificates.crt'
  @api_base = 'https://api.baabedo.com'
  @api_version = 'v1beta'
  @mutex = Mutex.new

  @ssl_bundle_path  = DEFAULT_CA_BUNDLE_PATH
  @verify_ssl_certs = true

  class << self
    attr_accessor :access_token, :api_base, :verify_ssl_certs, :api_version
  end

  def self.api_url(url='', api_base_url=nil)
    (api_base_url || @api_base) + url
  end

  def self.with_mutex
    @mutex.synchronize { yield }
  end

  def self.request(method, url, access_token, params={}, headers={}, api_base_url=nil)
    api_base_url = api_base_url || @api_base

    unless access_token ||= @access_token
      raise AuthenticationError.new('No API key provided. ' \
        'Set your API key using "Baabedo.access_token = <API-KEY>". ' \
        'You can currently only request an API key via out in-app support.')
    end

    if access_token =~ /\s/
      raise AuthenticationError.new('Your API key is invalid, as it contains ' \
        'whitespace.)')
#        'whitespace. (HINT: You can double-check your API key from the ' \
#        'Stripe web interface. See https://stripe.com/api for details, or ' \
#        'email support@stripe.com if you have any questions.)')
    end

    request_opts = {}
    if verify_ssl_certs
      request_opts = {:verify_ssl => OpenSSL::SSL::VERIFY_PEER,
                      :ssl_ca_file => @ssl_bundle_path}
    else
      request_opts = {:verify_ssl => false}
      unless @verify_ssl_warned
        @verify_ssl_warned = true
        $stderr.puts("WARNING: Running without SSL cert verification. " \
          "You should never do this in production. " \
          "Execute 'Baabedo.verify_ssl_certs = true' to enable verification.")
      end
    end

    params = Util.objects_to_ids(params)
    url = api_url(url, api_base_url)

    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      # Make params into GET parameters
      url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
      payload = nil
    else
      if headers[:content_type] && headers[:content_type] == "multipart/form-data"
        payload = params
      else
        payload = uri_encode(params)
      end
    end

    request_opts.update(:headers => request_headers(access_token).update(headers),
                        :method => method, :open_timeout => 30,
                        :payload => payload, :url => url, :timeout => 80)

    begin
      response = execute_request(request_opts)
    rescue SocketError => e
      handle_restclient_error(e, api_base_url)
    rescue NoMethodError => e
      # Work around RestClient bug
      if e.message =~ /\WRequestFailed\W/
        e = APIConnectionError.new('Unexpected HTTP response code')
        handle_restclient_error(e, api_base_url)
      else
        raise
      end
    rescue RestClient::ExceptionWithResponse => e
      if rcode = e.http_code and rbody = e.http_body
        handle_api_error(rcode, rbody)
      else
        handle_restclient_error(e, api_base_url)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      handle_restclient_error(e, api_base_url)
    end

    [parse(response), access_token]
  end

  private

  def self.uri_encode(params)
    Util.flatten_params(params).
      map { |k,v| "#{k}=#{Util.url_encode(v)}" }.join('&')
  end

  def self.request_headers(access_token)
    headers = {
      :user_agent => "Baabedo/v1 RubyBindings/#{Baabedo::VERSION}",
      :authorization => "Bearer #{access_token}",
      :content_type => 'application/x-www-form-urlencoded'
    }
  end

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.parse(response)
    begin
      # Would use :symbolize_names => true, but apparently there is
      # some library out there that makes symbolize_names not work.
      response = JSON.parse(response.body)
    rescue JSON::ParserError
      raise general_api_error(response.code, response.body)
    end

    Util.symbolize_names(response)
  end

  def self.general_api_error(rcode, rbody)
    APIError.new("Invalid response object from API: #{rbody.inspect} " +
                 "(HTTP response code was #{rcode})", rcode, rbody)
  end

  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = JSON.parse(rbody)
      error_obj = Util.symbolize_names(error_obj)
      error = error_obj[:error] or raise BaabedoError.new # escape from parsing

    rescue JSON::ParserError, BaabedoError
      raise general_api_error(rcode, rbody)
    end

    case rcode
    when 400, 404
      raise invalid_request_error error, rcode, rbody, error_obj
    when 401
      raise authentication_error error, rcode, rbody, error_obj
    when 402
      raise card_error error, rcode, rbody, error_obj
    else
      raise api_error error, rcode, rbody, error_obj
    end

  end

  def self.invalid_request_error(error, rcode, rbody, error_obj)
    InvalidRequestError.new(error[:message], error[:param], rcode,
                            rbody, error_obj)
  end

  def self.authentication_error(error, rcode, rbody, error_obj)
    AuthenticationError.new(error[:message], rcode, rbody, error_obj)
  end

  def self.card_error(error, rcode, rbody, error_obj)
    CardError.new(error[:message], error[:param], error[:code],
                  rcode, rbody, error_obj)
  end

  def self.api_error(error, rcode, rbody, error_obj)
    APIError.new(error[:message], rcode, rbody, error_obj)
  end

  def self.handle_restclient_error(e, api_base_url=nil)
    api_base_url = @api_base unless api_base_url
    connection_message = "Please check your internet connection and try again. " \
        "If this problem persists, let us know at api@baabedo.com."
#        "If this problem persists, you should check Baabedo's service status at " \
#        "https://twitter.com/baabedostatus, or let us know at api@baabedo.com."

    case e
    when RestClient::RequestTimeout
      message = "Could not connect to Baabedo (#{api_base_url}). #{connection_message}"

    when RestClient::ServerBrokeConnection
      message = "The connection to the server (#{api_base_url}) broke before the " \
        "request completed. #{connection_message}"

    when RestClient::SSLCertificateNotVerified
      message = "Could not verify Baabedo's SSL certificate. " \
        "Please make sure that your network is not intercepting certificates. " \
        "If this problem persists, let us know at api@baabedo.com."

    when SocketError
      message = "Unexpected error communicating when trying to connect to Baabedo. " \
        "You may be seeing this message because your DNS is not working. " \
        "To check, try running 'host baabedo.com' from the command line."

    else
      message = "Unexpected error communicating with Baabedo. " \
        "If this problem persists, let us know at api@baabedo.com."

    end

    raise APIConnectionError.new(message + "\n\n(Network error: #{e.message})")
  end
end
