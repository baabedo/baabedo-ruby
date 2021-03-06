module Baabedo
  module APIOperations
    module List
      module ClassMethods
        def all(params={}, opts={})
          opts = Util.normalize_opts(opts)

          response, opts = request(:get, url, params, opts)
          Util.convert_to_api_object(response, opts)
        end

        def url
          return build_url(params) if respond_to?(:build_url)
          super
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
