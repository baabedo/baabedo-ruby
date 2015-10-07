require 'baabedo'
require 'webmock/rspec'

describe Baabedo::Order do
  before do
    WebMock.disable_net_connect!
  end

  it '#all' do
    client = Baabedo::Client.new
    client.access_token = 'xxx'
    client.api_base = 'http://example.com'
    client.api_version = 'test'

    res_body = JSON.parse('
      { "type": "list.channel",
        "data": [
        {
            "type": "channel",
            "id": "2d2222fedbdf2dad",
            "company_id": "2009bfc",
            "display_name": "Amazon DE",
            "marketplace_type": "amazon",
            "marketplace_tld": "de",
            "merchant_id": "A19YNR",
            "mws_auth_token": "amzn.mws.2ca58110e817"
        }]
      }')

    stub = stub_request(:get, "http://example.com/test/channels").
      to_return(body: res_body.to_json)

    res_channels = client.use do
      Baabedo::Channel.all
    end

    expect(stub).to have_been_requested
    expect(res_channels.first).to be_a(Baabedo::Channel)
  end
end

