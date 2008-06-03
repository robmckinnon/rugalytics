module Rugalytics

  class Report
    attr_reader :base_url, :report_name, :start_date, :end_date, :items

    def initialize csv
      lines = csv.split("\n")
      @base_url = lines[1]
      @report_name = lines[2].chomp(',')
      dates = lines[3].split(',')
      @start_date = dates[0]
      @end_date = dates[1]
      @items = []

      index = 5
      return if index >= lines.size

      while (lines[index][/^# Table/].nil?)
        index = index.next
      end
      index = index+2
      attributes = lines[index].split(',')
      index = index.next
      while (values = lines[index]) && values[/^# -/].nil?
        @items << Item.new(attributes, values.split(','), base_url)
        index = index.next
      end
    end
  end

end