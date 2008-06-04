module Rugalytics

  class Graph

    attr_reader :name, :points

    def initialize name, period, points
      @name = name
      @period = period
      @points = points
    end

    def start_date
      @period.split('-')[0].strip
    end

    def end_date
      @period.split('-')[1].strip
    end
  end

end