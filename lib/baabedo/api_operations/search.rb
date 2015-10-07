module Baabedo
  module APIOperations
    module Search
      module ClassMethods
        def search(query, params={}, opts={})
          opts = Util.normalize_opts(opts)

          search_url = url(params) + '/_search'
          params = params.merge({query: query})
          response, opts = request(:get, search_url, params, opts)
          Util.convert_to_api_object(response, opts)
        end

        def url(params)
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
