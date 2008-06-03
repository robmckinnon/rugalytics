require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Report do

  describe "creating from csv" do

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
end