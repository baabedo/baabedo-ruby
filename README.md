# Baabedo Ruby bindings

Ruby bindings for the Baabedo API

**still under construction**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'baabedo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install baabedo

## Usage

Simple usage:

```
Baabedo.access_token = 'xxxxxxxxxxxxx'

Baabedo::Channel.all # list all channels
```

Advanced usage if you need to handle different access_tokens

```
client = Baabedo::Client.new
client.access_token = 'xxxxxxxxxxxxx'

# the access_token and any other configuration made on the client will only be used inside this block
client.use do
  Baabedo::Channel.all
end

```

## Contributing

### For bugfixes:

1. Fork it ( https://github.com/[my-github-username]/baabedo-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### For new features:

If you want to request a new feature in the API, please create an issue first. :)

## Thank you

A huge thank you to the Stripe team for stripe-ruby!

This gem is based on [stripe-ruby](https://github.com/stripe/stripe-ruby)
at [8ba1a0e4908cccf20198791aa8f72acc63575589](https://github.com/stripe/stripe-ruby/tree/8ba1a0e4908cccf20198791aa8f72acc63575589)
