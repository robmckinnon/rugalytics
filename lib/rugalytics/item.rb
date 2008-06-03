require 'morph'

module Rugalytics

  class Item
    include Morph

    def initialize attributes, values, base_url
      attributes.each_with_index do |attribute, index|
        attribute.sub!('$','dollar')
        morph(attribute, values[index])
      end

      self.url = "http://#{base_url}#{url}" if url
    end
  end

end