module Baabedo
  class Money < APIObject
    def initialize(fractional, currency=nil)
      super(nil)
      add_accessors([:fractional])
      add_accessors([:currency])
      self.fractional = fractional
      self.currency = currency unless currency.nil?
    end
  end
end
