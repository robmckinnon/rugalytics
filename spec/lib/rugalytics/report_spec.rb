require File.dirname(__FILE__) + '/../../spec_helper.rb'
include Rugalytics

describe Report do

  describe "creating report from csv" do

    describe "when setting report attributes" do
      before :all do
        csv = %Q|# ----------------------------------------
your_site.com
Top Content,
26 May 2008,31 May 2008
# ----------------------------------------|
        @report = Report.new(csv)
      end

      it "should set base url from second line of text" do
        @report.base_url.should == 'your_site.com'
      end

      it "should set report name from third line of text" do
        @report.report_name.should == 'Top Content'
      end

      it "should set start date from fourth line of text" do
        @report.start_date.should == Date.parse('26 May 2008')
      end

      it "should set end date from fourth line of text" do
        @report.end_date.should == Date.parse('31 May 2008')
      end
    end

    describe "when setting report dates" do
      describe "with source date format 'Month Day, Year'" do
        before :all do
          csv = %Q|# ----------------------------------------
your_site.com
Top Content,
"July 28, 2008","August 4, 2008"
# ----------------------------------------|
          @report = Report.new(csv)
        end
        it "should set start date from fourth line of text" do
          @report.start_date.should == Date.parse('28 July 2008')
        end
        it "should set end date from fourth line of text" do
          @report.end_date.should == Date.parse('4 August 2008')
        end
      end
      describe "with dates badly formatted" do
        it 'should raise an exception' do
          csv = %Q|# ----------------------------------------
your_site.com
Top Content,
random something
# ----------------------------------------|
          lambda { Report.new(csv) }.should raise_error(Exception, 'invalid date: random something')
        end
      end
    end

    describe "when creating items from 'Table'" do
      before :all do
        @base_url = %Q|your_site.com|
        @attributes = %Q|URL,Page Views,Unique Page Views,Time on Page,Bounce Rate,% Exit,$ Index|
        @values1 = %Q|/,189,157,54.94957983193277,0.4862385392189026,0.37037035822868347,0.0|
        @values2 = %Q|/bills,60,38,54.17307692307692,0.0,0.13333334028720856,0.0|
        @csv = %Q|# ----------------------------------------
#{@base_url}
Top Content,
26 May 2008,31 May 2008
# ----------------------------------------
# ----------------------------------------
# Table
# ----------------------------------------
#{@attributes}
#{@values1}
#{@values2}
# --------------------------------------------------------------------------------
|
      end

      it 'should create item for each data row in "Table"' do
        item1 = mock('item1')
        item2 = mock('item2')
        Item.should_receive(:new).with(@attributes.split(','), @values1.split(','), @base_url).and_return item1
        Item.should_receive(:new).with(@attributes.split(','), @values2.split(','), @base_url).and_return item2

        report = Report.new(@csv)
        report.items.should == [item1, item2]
      end
    end

    describe "when creating items from '.*MiniTableTable'" do
      before :all do
        @base_url = %Q|your_site.com|
        @browser_attributes = %Q|Browser,Visits,% visits|
        @browser_values = %Q|Firefox,1529,0.17185568809509277|
        @connection_speed_attributes = %Q|Connection Speed,Visits,% visits|
        @connection_speed_values = %Q|Unknown,3987,0.4481285810470581|
        @csv = %Q|# ----------------------------------------
#{@base_url}
Visitors Overview,
3 May 2008,2 June 2008
# ----------------------------------------
# ----------------------------------------
# BrowserMiniTable
# ----------------------------------------
#{@browser_attributes}
#{@browser_values}

# ----------------------------------------
# ConnectionSpeedMiniTable
# ----------------------------------------
#{@connection_speed_attributes}
#{@connection_speed_values}
# --------------------------------------------------------------------------------|
      end
      it 'should create item for each data row in "XxxMiniTable"' do
        browser_item = mock('browser_item')
        connection_item = mock('item')
        Item.should_receive(:new).with(@browser_attributes.split(','), @browser_values.split(','), @base_url).and_return browser_item
        Item.should_receive(:new).with(@connection_speed_attributes.split(','), @connection_speed_values.split(','), @base_url).and_return connection_item

        report = Report.new(@csv)
        report.browser_items.should == [browser_item]
        report.connection_speed_items.should == [connection_item]
        report.attribute_names.should == ['browser_items', 'connection_speed_items']
      end
    end

    describe "when creating graph points from 'Graph'" do
      def graph_correct expected_start, expected_end
        @start_end_dates = "#{@start},#{@end}"
        @name = %Q|Page Views|
        @csv = %Q|# ----------------------------------------
your_site.com
Top Content,
#{@start_end_dates}
# ----------------------------------------

# ----------------------------------------
# Graph
# ----------------------------------------
#{@period}
#{@name}
"5,360"
433|
        graph = mock('graph')
        Graph.should_receive(:new).with(@name, @period, [5360, 433], expected_start, expected_end).and_return graph

        report = Report.new(@csv)
        report.page_views_graph.should == graph
        report.attribute_names.should == ['page_views_graph']
      end

      describe 'with source date format "Month Day, Year"' do
        it 'should create graph with data under "Graph"' do
          @start = %Q|"July 5, 2008"|
          @end = %Q|"August 4, 2008"|
          @period = %Q|"July 5, 2008 - August 4, 2008"|
          graph_correct Date.new(2008,7,5), Date.new(2008,8,4)
        end
      end

      describe "with source date format 'Day Month Year'" do
        it 'should create graph with data under "Graph"' do
          @start = %Q|26 May 2008|
          @end = %Q|31 May 2008|
          @period = %Q|1 May 2008 - 31 May 2008|
          graph_correct Date.parse(@start), Date.parse(@end)
        end
      end
    end
  end

  describe 'when retrieving total using method not defined on class' do
    it 'should return total from graph named in method name' do
      report = Report.new
      report.should_receive(:respond_to?).with(:page_views_graph).and_return true
      report.should_receive(:page_views_graph).and_return mock('graph', :sum_of_points=>100)
      report.method_missing(:page_views_total).should == 100
    end
  end

  describe 'when retrieving list by day using method not defined on class' do
    it 'should return by day list from graph named in method name' do
      report = Report.new
      report.should_receive(:respond_to?).with(:page_views_graph).and_return true
      points_by_day = mock('points_by_day')
      report.should_receive(:page_views_graph).and_return mock('graph', :points_by_day=>points_by_day)
      report.method_missing(:page_views_by_day).should == points_by_day
    end
  end

end