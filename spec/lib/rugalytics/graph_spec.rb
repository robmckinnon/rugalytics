require File.dirname(__FILE__) + '/../../spec_helper.rb'
include Rugalytics

shared_examples_for "graph created correctly" do
  def graph_correct_for report_start, report_end, expected_points
    graph = Graph.new 'Page Views', @period, @points, report_start, report_end
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

describe Graph do

  describe 'when creating with dates formatted Day Month Year' do
    before :all do
      @period = '1 May 2008 - 3 May 2008'
      @points = [5360, 3330, 4330]
    end

    it_should_behave_like "graph created correctly"
  end

  describe 'when creating with dates formatted "Month Day, Year"' do
    before :all do
      @period = %Q|"May 1, 2008 - May 3, 2008"|
      @points = [5360, 3330, 4330]
    end

    it_should_behave_like "graph created correctly"
  end

end