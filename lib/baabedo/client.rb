module Baabedo
  class Client
    attr_accessor :access_token, :api_base, :api_version, :verify_ssl_certs, :proxy

    def use
      Baabedo.with_mutex do
        begin
          save = {}
          save[:access_token] = Baabedo.access_token
          save[:api_base] = Baabedo.api_base
          save[:api_version] = Baabedo.api_version
          save[:verify_ssl_certs] = Baabedo.verify_ssl_certs
          save[:proxy] = RestClient.proxy

          Baabedo.access_token = access_token if access_token
          Baabedo.api_base = api_base if api_base
          Baabedo.api_version = api_version if api_version
          Baabedo.verify_ssl_certs = verify_ssl_certs if verify_ssl_certs
          RestClient.proxy = proxy if proxy

          yield
        ensure
          Baabedo.access_token = save[:access_token]
          Baabedo.api_base = save[:api_base]
          Baabedo.api_version = save[:api_version]
          Baabedo.verify_ssl_certs = save[:verify_ssl_certs]
          RestClient.proxy = save[:proxy]
        end
      end
    end
  end
end
