module Baabedo
  class APIResource < APIObject
    include Baabedo::APIOperations::Request

    def self.class_name
      self.name.split('::')[-1]
    end

    def self.url
      if self == APIResource
        raise NotImplementedError.new('APIResource is an abstract class.  You should perform actions on its subclasses (Charge, Customer, etc.)')
      end
      type_endpoint = CGI.escape(class_name.downcase)
      case type_endpoint
      when /y$/
        type_endpoint = type_endpoint.gsub(/y$/, 'ies') # pluralize for companies
      else
        type_endpoint = "#{type_endpoint}s"
      end
      "/#{Baabedo.api_version}/#{type_endpoint}"
    end

    def url
      unless id = self['id']
        raise InvalidRequestError.new("Could not determine which URL to request: #{self.class} instance has invalid ID: #{id.inspect}", 'id')
      end
      "#{self.class.url}/#{CGI.escape(id)}"
    end

    def refresh
      response, opts = request(:get, url, @retrieve_params)
      refresh_from(response, opts)
    end

    def self.retrieve(id, opts={})
      opts = Util.normalize_opts(opts)
      instance = self.new(id, opts)
      instance.refresh
      instance
    end
  end
end
