describe Baabedo do
  it 'can set global access_token' do
    expect{Baabedo.access_token}.not_to raise_exception
    expect{Baabedo.access_token = 'a3d23'}.not_to raise_exception
  end
end
