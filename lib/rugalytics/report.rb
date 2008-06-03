module Rugalytics

  class Report
    attr_reader :base_url, :report_name, :start_date, :end_date

    def initialize csv
      lines = csv.split("\n")
      @base_url = lines[1]
      @report_name = lines[2].chomp(',')
      dates = lines[3].split(',')
      @start_date = dates[0]
      @end_date = dates[1]
    end
  end

end