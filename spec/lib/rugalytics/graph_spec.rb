require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Graph, 'when creating' do

  before :all do
    @period = '1 May 2008 - 2 May 2008'
    @name = 'Page Views'
    @points = [5360, 4330]
  end

  it "it should create fields for attributes and values" do
    graph = Rugalytics::Graph.new @name, @period, @points

    graph.start_date.should == '1 May 2008'
    graph.end_date.should == '2 May 2008'

    graph.points.should == @points
  end

end