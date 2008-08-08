module Rugalytics

  class Item
    include Morph

    def initialize attributes, values, base_url
      attributes.each_with_index do |attribute, index|
        attribute.sub!('$','dollar')
        attribute.sub!('/',' per ')
        attribute.sub!('.',' ')
        attribute.sub!(/page views/i,'pageviews')
        value = values[index]
        morph(attribute, value)
      end

      if respond_to?(:url)
        self.path = url
        # todo: For drilldown report, URLs need to be cumulatively created e.g. /health/ -> http://theyworkforyou.co.nz/portfolios/health/
        self.url = "http://#{base_url}#{url}"
      end
    end
  end

end