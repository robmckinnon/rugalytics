module Rugalytics
  class Item
    include Morph

    def initialize labels, values, base_url
      labels.each_with_index do
          |label, index|
        attribute = normalize(label)
        value = values[index]
        morph(attribute, value)
      end

      if respond_to?(:page)
        self.path = page
        # todo: For drilldown report, URLs need to be cumulatively created e.g. /health/ -> http://theyworkforyou.co.nz/portfolios/health/
        self.url = "http://#{base_url}#{page}"
      end
    end

    private
    def normalize label
      label.sub!('$','dollar')
      label.sub!('/',' per ')
      label.sub!('.',' ')
      label.sub!(/page views/i,'pageviews')
      label
    end
  end

end