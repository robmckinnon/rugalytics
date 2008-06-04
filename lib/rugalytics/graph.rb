module Rugalytics
  class Graph

    attr_reader :name, :points, :from, :to

    def initialize name, period, points
      @name = name
      @period = period
      dates = @period.split('-')
      unless dates.empty?
        @from = Date.parse(dates[0].strip)
        @to = Date.parse(dates[1].strip)
      end
      @points = points
    end

    def sum_of_points
      points.sum
    end

    def points_by_day
      by_day = []
      index = 0
      from.upto(to) do |date|
        by_day << [date, points[index] ]
        index = index.next
      end
      by_day
    end
  end
end