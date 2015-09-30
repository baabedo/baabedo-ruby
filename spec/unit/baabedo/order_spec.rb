require 'baabedo'
require 'webmock/rspec'

describe Baabedo::Order do
  before do
    WebMock.disable_net_connect!
  end
  it 'retrieve requests correct url' do
    client = Baabedo::Client.new
    client.api_base = 'http://example.com'
    client.api_version = 'test'
    client.use do
      ord = Baabedo::Order.new('3ea8cd7e9d16e5f5799d9c5f', channel_id: '2d2222fedbdf2dad')
      expect(ord.url).to eq('/test/channels/2d2222fedbdf2dad/orders/3ea8cd7e9d16e5f5799d9c5f')
    end
  end

  it 'can update status without fetching first' do
    client = Baabedo::Client.new
    client.access_token = 'xxx'
    client.api_base = 'http://example.com'
    client.api_version = 'test'

    res_body = JSON.parse('
        {
            "channel_id": "2d2222fedbdf2dad",
            "created_at": 1443541843,
            "custom": null,
            "extra_price": null,
            "id": "3ea8cd7e9d16e5f5799d9c5f",
            "items_price": null,
            "order_items": null,
            "purchased_at": 1443541250,
            "shipping_price": null,
            "status": "open",
            "status_updated_at": 0,
            "taxes_price": null,
            "total_price": null,
            "type": "order",
            "updated_at": 1443541843
        }
      ')

    stub = stub_request(:put, "http://example.com/test/channels/2d2222fedbdf2dad/orders/3ea8cd7e9d16e5f5799d9c5f").
      with(body: { status: 'open' }).
      to_return(body: res_body.to_json)
    res_ord = client.use do
      ord = Baabedo::Order.new('3ea8cd7e9d16e5f5799d9c5f', channel_id: '2d2222fedbdf2dad')
      ord.status = 'open'
      ord.save
    end

    expect(stub).to have_been_requested
    expect(res_ord).to be_a(Baabedo::Order)
  end

  it 'can update items_price with money object' do
    client = Baabedo::Client.new
    client.access_token = 'xxx'
    client.api_base = 'http://example.com'
    client.api_version = 'test'

    res_body = JSON.parse('
        {
            "channel_id": "2d2222fedbdf2dad",
            "created_at": 1443541843,
            "custom": null,
            "extra_price": null,
            "id": "3ea8cd7e9d16e5f5799d9c5f",
            "items_price": { "type": "money", "fraction": 4500, "currency": "EUR"},
            "order_items": null,
            "purchased_at": 1443541250,
            "shipping_price": null,
            "status": null,
            "status_updated_at": 0,
            "taxes_price": null,
            "total_price": null,
            "type": "order",
            "updated_at": 1443541843
        }
      ')

    stub = stub_request(:put, "http://example.com/test/channels/2d2222fedbdf2dad/orders/3ea8cd7e9d16e5f5799d9c5f").
      with(body: { items_price: { fractional: 4500, currency: 'EUR' } }).
      to_return(body: res_body.to_json)
    res_ord = client.use do
      ord = Baabedo::Order.new('3ea8cd7e9d16e5f5799d9c5f', channel_id: '2d2222fedbdf2dad')
      ord.items_price = Baabedo::Money.new(4500, 'EUR')
      ord.save
    end

    expect(stub).to have_been_requested
    expect(res_ord).to be_a(Baabedo::Order)
  end

  it 'can update custom attribute with hash' do
    client = Baabedo::Client.new
    client.access_token = 'xxx'
    client.api_base = 'http://example.com'
    client.api_version = 'test'

    res_body = JSON.parse('
        {
            "channel_id": "2d2222fedbdf2dad",
            "created_at": 1443541843,
            "custom": {"foo": "bar"},
            "extra_price": null,
            "id": "3ea8cd7e9d16e5f5799d9c5f",
            "items_price": null,
            "order_items": null,
            "purchased_at": 1443541250,
            "shipping_price": null,
            "status": null,
            "status_updated_at": 0,
            "taxes_price": null,
            "total_price": null,
            "type": "order",
            "updated_at": 1443541843
        }
      ')

    stub = stub_request(:put, "http://example.com/test/channels/2d2222fedbdf2dad/orders/3ea8cd7e9d16e5f5799d9c5f").
      with(body: { custom: { foo: "bar" } }).
      to_return(body: res_body.to_json)
    res_ord = client.use do
      ord = Baabedo::Order.new('3ea8cd7e9d16e5f5799d9c5f', channel_id: '2d2222fedbdf2dad')
      ord.custom = { foo: 'bar'}
      ord.save
    end

    expect(stub).to have_been_requested
    expect(res_ord).to be_a(Baabedo::Order)
    expect(res_ord.custom['foo']).to eq('bar')
  end
end
