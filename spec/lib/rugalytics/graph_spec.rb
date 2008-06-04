require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Graph do

  describe 'when creating' do

    before :all do
      @period = '1 May 2008 - 3 May 2008'
      @name = 'Page Views'
      @points = [5360, 3330, 4330]
    end

    it "should create fields for attributes and values" do
      graph = Rugalytics::Graph.new @name, @period, @points

      graph.from.should == Date.parse('2008-05-01')
      graph.to.should == Date.parse('2008-05-03')

      graph.points.should == @points
    end

  end

  describe 'when counting total of points' do
    it 'should sum points in graph' do
      graph = Rugalytics::Graph.new '','',[5360, 3330, 4330]
      graph.sum_of_points.should == 5360 + 3330 + 4330
    end
  end

  describe 'when counting total of points' do
    it 'should sum points in graph' do
      graph = Rugalytics::Graph.new '','',[5360, 3330, 4330]
      from = Date.parse('1 May 2003')
      mid = Date.parse('2 May 2003')
      to = Date.parse('3 May 2003')
      graph.stub!(:from).and_return from
      graph.stub!(:to).and_return to
      graph.points_by_day.should == [[from,5360],[mid,3330],[to,4330]]
    end
  end

end