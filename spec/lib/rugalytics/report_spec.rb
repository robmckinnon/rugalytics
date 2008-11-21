require File.dirname(__FILE__) + '/../../spec_helper.rb'
include Rugalytics

describe Report do

  describe "creating report from csv" do

    describe "when setting report attributes" do
      before :all do
        csv = ['# ----------------------------------------',
                'your_site.com',
                'Top Content,',
                '26 May 2008,31 May 2008',
                '# ----------------------------------------']
        @report = Report.new(csv.join("\n"))
      end

      it "should set base url from second line of text" do
        @report.base_url.should == 'your_site.com'
      end

      it "should set report name from third line of text" do
        @report.name.should == 'Top Content'
      end

      it "should set start date from fourth line of text" do
        @report.start_date.should == Date.parse('26 May 2008')
      end

      it "should set end date from fourth line of text" do
        @report.end_date.should == Date.parse('31 May 2008')
      end

      describe "for a Content Drilldown report and a path is in report name" do
        before :all do
          csv = ['# ----------------------------------------',
                  'your_site.com',
                  'Content Drilldown,/portfolios/health/',
                  '26 May 2008,31 May 2008',
                  '# ----------------------------------------']
          @report = Report.new(csv.join("\n"))
        end
        it 'should append path at end of base_url' do
          @report.base_url.should == 'your_site.com/portfolios/health'
        end
        it 'should set report name including path' do
          @report.name.should == 'Content Drilldown,/portfolios/health/'
        end
      end

      describe "for a Top Content by title report and page title is in report name" do
        before :all do
          csv = ['# ----------------------------------------',
                  'your_site.com',
                  'Content by Title Detail:,Project ABC | Company XZY',
                  '26 May 2008,31 May 2008',
                  '# ----------------------------------------']
          @report = Report.new(csv.join("\n"))
        end
        it 'should not append title to end of base_url' do
          @report.base_url.should == 'your_site.com'
        end
        it 'should set report name including page title' do
          @report.name.should == 'Content by Title Detail:,Project ABC | Company XZY'
        end
      end
    end

    describe "when setting report dates" do
      describe "with source date format 'Month Day, Year'" do
        before :all do
          csv = ['# ----------------------------------------',
                'your_site.com',
                'Top Content,',
                '"July 28, 2008","August 4, 2008"',
                '# ----------------------------------------']
          @report = Report.new(csv.join("\n"))
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
          csv = ['# ----------------------------------------',
                'your_site.com',
                'Top Content,',
                'random something',
                '# ----------------------------------------']
          lambda { Report.new(csv.join("\n")) }.should raise_error(Exception, 'invalid date: random something')
        end
      end
    end

    describe "when creating items from 'Table'" do
      before :all do
        @base_url = %Q|your_site.com|
        @attributes = %Q|URL,Page Views,Unique Page Views,Time on Page,Bounce Rate,% Exit,$ Index, Keyword|
        @values1 = %Q|/,189,157,54.94957983193277,0.4862385392189026,0.37037035822868347,0.0,"ABC, Project"|
        @values2 = %Q|/bills,60,38,54.17307692307692,0.0,0.13333334028720856,0.0,""new zealand"" house ""begins with h""|
        @csv = ['# ----------------------------------------',
                @base_url,
                'Top Content,',
                '26 May 2008,31 May 2008',
                '# ----------------------------------------',
                '# ----------------------------------------',
                '# Table',
                '# ----------------------------------------',
                @attributes,
                @values1,
                @values2,
                '# --------------------------------------------------------------------------------']
      end

      it 'should create item for each data row in "Table"' do
        item1 = mock('item1')
        item2 = mock('item2')
        array1 = ['/','189','157','54.94957983193277','0.4862385392189026','0.37037035822868347','0.0',"ABC, Project"]
        array2 = ['/bills','60','38','54.17307692307692','0.0','0.13333334028720856','0.0','"new zealand" house "begins with h"']
        Item.should_receive(:new).with(@attributes.split(','), array1, @base_url).and_return item1
        Item.should_receive(:new).with(@attributes.split(','), array2, @base_url).and_return item2

        report = Report.new(@csv.join("\n"))
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
        @csv = ['# ----------------------------------------',
                @base_url,
                'Visitors Overview',
                '3 May 2008,2 June 2008',
                '# ----------------------------------------',
                '# ----------------------------------------',
                '# BrowserMiniTable',
                '# ----------------------------------------',
                @browser_attributes,
                @browser_values,
                '',
                '# ----------------------------------------',
                '# ConnectionSpeedMiniTable',
                '# ----------------------------------------',
                @connection_speed_attributes,
                @connection_speed_values,
                '# --------------------------------------------------------------------------------']
      end
      it 'should create item for each data row in "XxxMiniTable"' do
        browser_item = mock('browser_item')
        connection_item = mock('item')
        Item.should_receive(:new).with(@browser_attributes.split(','), @browser_values.split(','), @base_url).and_return browser_item
        Item.should_receive(:new).with(@connection_speed_attributes.split(','), @connection_speed_values.split(','), @base_url).and_return connection_item

        report = Report.new(@csv.join("\n"))
        report.browser_items.should == [browser_item]
        report.connection_speed_items.should == [connection_item]
        report.attribute_names.should == ['browser_items', 'connection_speed_items']
      end
    end

    describe "when creating graph points from 'Graph'" do
      def graph_correct expected_start, expected_end, column_name='Page Views', graph_name=:pageviews_graph
        @start_end_dates = "#{@start},#{@end}"
        @point_labels=['20080828', '20080829'] unless @point_labels
        @label1 = @point_labels[0]
        @label2 = @point_labels[1]
        @name = column_name
        @column_names = "Day,#{@name}"
        @csv = ['# ----------------------------------------',
                'your_site.com',
                'Top Content,',
                @start_end_dates,
                '# ----------------------------------------',
                '',
                '# ----------------------------------------',
                '# Graph',
                '# ----------------------------------------',
                @column_names,
                %Q|#{@label1},"5,360"|,
                %Q|#{@label2},575|,
                '# ----------------------------------------']
        graph = mock('graph')

        Graph.should_receive(:new).with(@name.sub('/','_per_').sub('.',''), [5360, 575], expected_start, expected_end).and_return graph

        report = Report.new(@csv.join("\n"))
        report.send(graph_name).should == graph
        report.attribute_names.should == [graph_name.to_s]
      end

      describe 'with source date format "Month Day, Year"' do
        before do
          @start = %Q|"August 28, 2008"|
          @end = %Q|"August 29, 2008"|
        end
        it 'should create graph with data under "Graph"' do
          graph_correct Date.new(2008,8,28), Date.new(2008,8,29)
        end
        describe 'with graph point date format "Month Day, Year"' do
          it 'should create graph with data under "Graph"' do
            @point_labels = [@start,@end]
            graph_correct Date.new(2008,8,28), Date.new(2008,8,29)
          end
        end
      end

      describe "with source date format 'Day Month Year'" do
        before do
          @start = %Q|28 August 2008|
          @end = %Q|29 August 2008|
        end
        it 'should create graph with data under "Graph"' do
          graph_correct Date.parse(@start), Date.parse(@end)
        end
        describe 'with graph point date format "Day Month Year"' do
          it 'should create graph with data under "Graph"' do
            @point_labels = [@start, @end]
            graph_correct Date.parse(@start), Date.parse(@end)
          end
        end
        describe "with forward slash in column name" do
          it 'should create graph with forward slash replaced by _per_ in column name' do
            graph_correct Date.parse(@start), Date.parse(@end), 'Pages/Visit', :pages_per_visit_graph
          end
        end
        describe "with dot in column name" do
          it 'should create graph with dot removed in column name' do
            graph_correct Date.parse(@start), Date.parse(@end), 'Avg. Time on Site', :avg_time_on_site_graph
          end
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