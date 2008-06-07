require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Graph do

  describe 'when creating' do

    before :all do
      @period = '1 May 2008 - 3 May 2008'
      @name = 'Page Views'
      @points = [5360, 3330, 4330]
    end

    def graph_correct_for report_start, report_end, expected_points
      graph = Rugalytics::Graph.new @name, @period, @points, report_start, report_end
      graph.from.should == report_start
      graph.to.should == report_end
      graph.points.should == expected_points
      graph
    end

    it "should set given points on graph" do
      graph_correct_for Date.parse('2008-05-01'), Date.parse('2008-05-03'), @points
    end

    it "should set appropriate point on graph when report start and end is the same date" do
      graph_correct_for Date.parse('2008-05-01'), Date.parse('2008-05-01'), [@points[0]]
    end

    it "should set appropriate points on graph when report start and end is a subset of the graph period" do
      graph_correct_for Date.parse('2008-05-02'), Date.parse('2008-05-03'), [@points[1],@points[2]]
    end

    it 'should set points by day' do
      from = Date.parse('1 May 2008')
      to = Date.parse('3 May 2008')
      mid = Date.parse('2 May 2008')
      graph = graph_correct_for from, to, @points
      graph.points_by_day.should == [[from,5360],[mid,3330],[to,4330]]
    end

    it 'should return sum of points' do
      graph = graph_correct_for Date.parse('2008-05-01'), Date.parse('2008-05-03'), @points
      graph.sum_of_points.should == 5360 + 3330 + 4330
    end
  end

end