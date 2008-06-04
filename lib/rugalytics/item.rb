module Rugalytics

  class Item
    include Morph

    def initialize attributes, values, base_url
      attributes.each_with_index do |attribute, index|
        attribute.sub!('$','dollar')
        attribute.sub!('/',' per ')
        attribute.sub!('.',' ')
        value = values[index]
        morph(attribute, value)
      end

      self.url = "http://#{base_url}#{url}" if respond_to?(:url)
    end
  end

end