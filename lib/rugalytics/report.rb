module Rugalytics

  class Report

    include MorphLessMethodMissing

    attr_reader :base_url, :start_date, :end_date, :name

    def initialize csv=''
      return if csv.empty?
      lines = csv.split("\n")
      set_attributes lines
      handle_graphs lines
      handle_tables lines
    end

    def attributes
      morph_attributes.delete_if {|k,v| v.nil?}.stringify_keys
    end

    def attribute_names
      attributes.keys
    end

    def method_missing symbol, *args
      if is_writer = symbol.to_s[/=$/]
        morph_method_missing(symbol, *args)

      elsif symbol.to_s.match(/(.*)_(total|by_day)/)
        graph = "#{$1}_graph".to_sym

        if respond_to?(graph)
          $2 == 'total' ? send(graph).sum_of_points : send(graph).points_by_day
        else
          super
        end

      else
        super
      end
    end

    private

    def set_attributes lines
      @base_url = lines[1]
      names = lines[2].split(',')
      @base_url = "#{@base_url}#{names[1].chomp('/')}" if names.size > 1 && names[1][/^\/.+$/]
      @name = lines[2].chomp(',')
      dates = lines[3].include?('","') ? lines[3].split('","') : lines[3].split(',')

      @start_date = Rugalytics.i18n_date_parse(dates[0])
      @end_date = Rugalytics.i18n_date_parse(dates[1])
    end

    def date_from_point date_point
      date_point[/^\d\d\d\d\d\d\d\d,/] || date_point[/^".+",/] || date_point[/^[^,]+,/]
    end

    def handle_graphs lines
      index = 5
      while index < lines.size
        while (lines[index][/^# Graph/].nil? || lines[index].strip.size == 0)
          index = index.next
          return if index == lines.size
        end
        index = index + 2
        column_names = lines[index]
        name = column_names.split(',').last
        index = index.next

        points = []
        while (date_point = lines[index]) && (date = date_from_point(date_point))
          point = date_point.sub(date,'')
          points << point.tr('",','').to_i
          index = index.next
        end

        name = name.gsub('/','_per_').gsub('.','')
        graph = Graph.new name, points, start_date, end_date
        morph("#{name.sub(/page views/i,'pageviews')} graph", graph)
      end
    end

    def handle_tables lines
      index = 5
      while index < lines.size
        while (lines[index][/^# .*Table/].nil? || lines[index].blank?)
          index = index.next
          return if index == lines.size
        end
        type = lines[index][/^# (.*)MiniTable/,1]
        index = index + 2
        attributes = lines[index].split(',')
        index = index.next

        items = []
        items_attribute = (type && type.size > 0) ? "#{type.gsub(/([a-z])([A-Z])/, '\1_\2').downcase}_items" : 'items'
        morph(items_attribute, items)

        while (values_line = lines[index]) && values_line[/^# -/].nil? && values_line.strip.size > 0
          begin
            values = FasterCSV.parse_line(values_line)
          rescue Exception => e
            values_line.gsub!(/""/,'^$$^')
            values = FasterCSV.parse_line(values_line)
            values.each {|v| v.gsub!('^$$^','"')}
          end
          items << Item.new(attributes, values, base_url)
          index = index.next
        end
      end
    end
  end
end