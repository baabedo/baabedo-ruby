module Baabedo
  class Order < APIResource
    include Baabedo::APIOperations::Create
    include Baabedo::APIOperations::Update
    include Baabedo::APIOperations::Delete

    def url
      channel_id = @opts[:channel_id]
      fail 'no :channel_id option provided' if channel_id.nil?

      ch = Channel.new(channel_id)
      ch.url + '/orders/' + id
    end
  end
end
