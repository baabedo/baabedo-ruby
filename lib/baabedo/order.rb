module Baabedo
  class Order < APIResource
    include Baabedo::APIOperations::Create
    include Baabedo::APIOperations::Update
    include Baabedo::APIOperations::Delete
    include Baabedo::APIOperations::List
    include Baabedo::APIOperations::Search

    def url
      channel_id = @opts[:channel_id]
      self.class.build_url(channel_id: channel_id, id: id)
    end

    def self.build_url(params = {})
      channel_id = params.delete(:channel_id)
      fail 'no :channel_id option provided' if channel_id.nil?

      ch = Channel.new(channel_id)
      url = ch.url + '/orders'
      url = url + '/' + params[:id] if params[:id]

      url
    end
  end
end
