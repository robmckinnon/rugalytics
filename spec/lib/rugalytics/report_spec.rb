require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Report do

  describe "creating report from csv" do

    describe "when setting report attributes" do
      before :all do
        csv = %Q|# ----------------------------------------
theyworkforyou.co.nz
Top Content,
26 May 2008,31 May 2008
# ----------------------------------------|
        @report = Rugalytics::Report.new(csv)
      end

      it "should set base url from second line of text" do
        @report.base_url.should == 'theyworkforyou.co.nz'
      end

      it "should set report name from third line of text" do
        @report.report_name.should == 'Top Content'
      end

      it "should set start date from fourth line of text" do
        @report.start_date.should == '26 May 2008'
      end

      it "should set end date from fourth line of text" do
        @report.end_date.should == '31 May 2008'
      end
    end

    describe "when creating items" do
      before :all do
        @base_url = %Q|theyworkforyou.co.nz|
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
        Rugalytics::Item.should_receive(:new).with(@attributes.split(','), @values1.split(','), @base_url).and_return item1
        Rugalytics::Item.should_receive(:new).with(@attributes.split(','), @values2.split(','), @base_url).and_return item2

        report = Rugalytics::Report.new(@csv)
        report.items.should == [item1, item2]
      end
    end
  end
end