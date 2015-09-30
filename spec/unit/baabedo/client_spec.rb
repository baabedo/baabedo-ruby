require 'baabedo'
describe Baabedo::Client do
  it 'can be instantiated' do
    expect{Baabedo::Client.new}.not_to raise_exception
  end

  it 'resets values when exception is thrown during #use' do
    Baabedo.access_token = 'originaltoken'
    expect{
      client = Baabedo::Client.new
      client.access_token = 'differenttoken'
      client.use do
        fail
      end}.to raise_exception

    expect(Baabedo.access_token).to eq('originaltoken')
  end
end
