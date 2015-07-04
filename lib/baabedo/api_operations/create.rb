module Baabedo
  module APIOperations
    module Create
      module ClassMethods
        def create(params={}, opts={})
          response, opts = request(:post, url, params, opts)
          Util.convert_to_api_object(response, opts)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
