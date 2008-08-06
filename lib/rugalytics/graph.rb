module Rugalytics
  class Graph

    attr_reader :name, :points, :points_by_day, :from, :to

    def initialize name, graph_period, points, report_start, report_end
      @name = name
      @from = report_start
      @to = report_end
      @points_by_day = create_points_by_day points, graph_period, report_start, report_end
      @points = points_by_day.collect{|by_day| by_day[1]}
    end

    def sum_of_points
      points.sum
    end

    private

    def create_points_by_day points, graph_period, report_start, report_end
      with_dates_from_period(graph_period, []) do |date, index, list|
        list << [date, points[index] ] if date >= report_start && date <= report_end
      end
    end

    def with_dates_from_period period, list
      dates = period.split('-')
      from = Rugalytics.i18n_date_parse(dates[0].strip)
      to = Rugalytics.i18n_date_parse(dates[1].strip)

      index = 0
      from.upto(to) do |date|
        yield date, index, list
        index = index.next
      end
      list
    end
  end
end