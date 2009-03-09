require File.dirname(__FILE__) + '/../../spec_helper.rb'
include Rugalytics

describe Profile do

  describe "being initialized" do
    it "should accept :name as key" do
      profile = Profile.new(:name => 'test', :profile_id => '12341234')
      profile.name.should == 'test'
    end
    it "should accept :account_id as key" do
      profile = Profile.new(:account_id => '12341234', :profile_id => '12341234')
      profile.account_id.should == '12341234'
    end
    it "should accept :profile_id as key" do
      profile = Profile.new(:profile_id => '12341234')
      profile.profile_id.should == '12341234'
    end
  end

  describe "finding by account id and profile id" do
    it 'should find account and find profile' do
      account_id = 1254221
      profile_id = 12341234
      account = mock('account')
      profile = mock('profile')

      Account.should_receive(:find).with(1254221).and_return account
      account.should_receive(:find_profile).with(profile_id).and_return profile
      Profile.find(account_id, profile_id).should == profile
    end
  end

  describe 'finding report names' do
    before do
      @profile = Profile.new :profile_id=>123
    end

    it 'should return list of reports linked from main profile page' do
      report = {}
      report[0] = 'os_browsers'
      report[1] = 'colors'
      report[2] = 'dashboard'
      report[3] = 'visits'
      report[4] = 'unique_visitors'
      report[5] = 'pageviews'
      report[6] = 'average_pageviews'
      report[7] = 'time_on_site'
      report[8] = 'bounce_rate'
      report[9] = 'visitor_types'
      report[10] = 'languages'
      report[11] = 'networks'
      report[13] = 'browsers'
      report[14] = 'platforms'
      report[15] = 'maps'
      report[16] = 'sources'
      report[17] = 'visitors'
      report[18] = 'resolutions'
      report[19] = 'java'
      report[20] = 'flash'
      report[21] = 'loyalty'
      report[22] = 'recency'
      report[23] = 'content'
      html = %Q|<html><head><title>Visitors Overview - Google Analytics</title></head>
<body dir="ltr" class="report_body">
<a href="#" onclick="return VisualizationModule.changeReport(&#39;add_segment&#39;);">Create a new advanced segment</a>
<a href="#" id="f_managesegment_format" onclick="return VisualizationModule.changeReport(&#39;manage_segments&#39;);">Manage your advanced segments</a>
<b> Your report has been added.<a href="dashboard?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[2]}&#39;)">View Dashboard</a>
<a href="visits?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&quot;#{report[3]}&quot;);"> Visits </a>
<a href="unique_visitors?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&quot;#{report[4]}&quot;);"> Absolute Unique Visitors </a>
<a href="pageviews?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&quot;#{report[5]}&quot;);"> Pageviews </a>
<a href="average_pageviews?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&quot;#{report[6]}&quot;);"> Average Pageviews </a>
<a href="time_on_site?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&quot;#{report[7]}&quot;);"> Time on Site </a>
<a href="bounce_rate?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&quot;#{report[8]}&quot;);"> Bounce Rate </a>
<a href="visitor_types?id=321&amp;pdr=20081020-20081119&amp;cmp=average&amp;view=1" onclick="return VisualizationModule.changeReport(&quot;#{report[9]}&quot;, &quot;view\x3d1&quot;);"> New Visits</a>
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[10]}&quot;)">languages</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[11]}&quot;)">network locations</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;user_defined&quot;)">user defined</a>
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[13]}&quot;, &quot;view=1&quot;)">browsers</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[14]}&quot;, &quot;view=1&quot;)">operating systems</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[0]}&quot;, &quot;view=1&quot;)">browser and operating systems</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[1]}&quot;, &quot;view=1&quot;)">screen colors</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[18]}&quot;, &quot;view=1&quot;)">screen resolutions</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[19]}&quot;, &quot;view=1&quot;, &quot;view=1&quot;)">java support</a>,
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[20]}&quot;, &quot;view=1&quot;, &quot;view=1&quot;)">Flash</a>
<a href="#" onclick="VisualizationModule.changeReport(&quot;#{report[15]}&quot;)">Map Overlay</a>
<a href="browsers?id=321&amp;pdr=20081020-20081119&amp;cmp=average&amp;view=1" onclick="return VisualizationModule.changeReport(&quot;browsers&quot;, &quot;view\x3d1&quot;);"> view full report</a>
<a href="speeds?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return Vis            <a href="dashboard?dashboard=1&amp;id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;dashboard&#39;)" class="" id="dashboard_nav_item">
<a href="visitors?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[17]}&#39;)" class="current" id="visitors_nav_item">
<a href="visitors?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;visitors&#39;)" class="current">
<a href="benchmark?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReportAndComparison(&#39;benchmark&#39;, &#39;benchmark&#39;)" class="">
<a href="maps?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[15]}&#39;)" class="">
<a href="visitor_types?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;visitor_types&#39;, &#39;view=1&#39;)" class="">
<a href="languages?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;languages&#39;)" class="">
<a href="visits?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;visits&#39;)" class="">
<a href="unique_visitors?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;unique_visitors&#39;)" class="">
<a href="pageviews?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;pageviews&#39;)" class="">
<a href="average_pageviews?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;average_pageviews&#39;)" class="">
<a href="time_on_site?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;time_on_site&#39;)" class="">
<a href="bounce_rate?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;bounce_rate&#39;)" class="">
<a href="loyalty?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[21]}&#39;)" class="">
<a href="recency?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[22]}&#39;)" class="">
<a href="user_defined?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;user_defined&#39;)" class="">
<a href="sources?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[16]}&#39;)" class="" id="traffic_sources_nav_item">
<a href="content?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;#{report[23]}&#39;)" class="" id="content_nav_item">
<a href="goal_intro?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;goal_intro&#39;)" class="" id="goals_nav_item">
<a href="custom_reports_overview?id=321&amp;pdr=20081020-20081119&amp;cmp=average" onclick="return VisualizationModule.changeReport(&#39;custom_reports_overview&#39;)" class="custom_reporting_section" id="custom_report_nav_item">
<a href="#" onclick="return VisualizationModule.changeReport(&quot;manage_segments&quot;);">Advanced Segments</a>&nbsp;<b class="beta_label small">Beta</b>
<a href="#" onclick="return VisualizationModule.changeReport(&quot;manage_emails&quot;);">Email</a>
</body></html>|
      Profile.should_receive(:get).with("https://www.google.com/analytics/reporting/?scid=#{@profile.profile_id}").and_return html

      report.values.each do |name|
        Profile.stub!(:get).with("https://www.google.com/analytics/reporting/#{name}?id=#{@profile.profile_id}").and_return ''
      end

      reports = @profile.report_names
      report.each do |k,name|
        report_name = "#{name.sub(/^maps$/,'geo_map').sub(/^sources$/,'traffic_sources').sub(/^visitors$/,'visitors_overview')}_report"
        reports.should include(report_name)
      end
    end

  end

  describe 'finding pageviews' do
    before do
      @profile = Profile.new :profile_id=>123
      @report = mock('report',:pageviews_total=>100)
    end
    it 'should return total from loaded "Pageviews" report' do
      @profile.should_receive(:pageviews_report).with({}).and_return @report
      @profile.pageviews.should == @report.pageviews_total
    end
    describe 'when from and to dates are specified' do
      it 'should return total from "Pageviews" report for given dates' do
        options = {:from=>'2008-05-01', :to=>'2008-05-03'}
        @profile.should_receive(:pageviews_report).with(options).and_return @report
        @profile.pageviews(options).should == @report.pageviews_total
      end
    end
  end

  describe 'finding visits' do
    before do
      @profile = Profile.new :profile_id=>123
      @report = mock('report', :visits_total=>100)
    end
    it 'should return total from loaded "Visits" report' do
      @profile.should_receive(:visits_report).with({}).and_return @report
      @profile.visits.should == @report.visits_total
    end
    describe 'when from and to dates are specified' do
      it 'should return total from "Visits" report for given dates' do
        options = {:from=>'2008-05-01', :to=>'2008-05-03'}
        @profile.should_receive(:visits_report).with(options).and_return @report
        @profile.visits(options).should == @report.visits_total
      end
    end
  end

  describe 'finding report when called with method ending in _report' do
    before do
      @profile = Profile.new :profile_id=>123
      @report = mock('report', :visits_total=>100)
    end
    it 'should find report using create_report method' do
      @profile.should_receive(:create_report).with('Visits',{}).and_return @report
      @profile.visits_report.should == @report
    end
    it 'should find instantiate report with report csv' do
      csv = 'csv'
      @profile.should_receive(:get_report_csv).with({:report=>'Visits'}).and_return csv
      @report.stub!(:attribute_names).and_return ''
      Report.should_receive(:new).with(csv).and_return @report
      @profile.visits_report.should == @report
    end
    describe 'when report name is two words' do
      it 'should find report using create_report method' do
        @profile.should_receive(:create_report).with('VisitorsOverview',{}).and_return @report
        @profile.visitors_overview_report.should == @report
      end
    end
    describe 'when dates are given' do
      it 'should find report using create_report method passing date options' do
        options = {:from=>'2008-05-01', :to=>'2008-05-03'}
        @profile.should_receive(:create_report).with('Visits', options).and_return @report
        @profile.visits_report(options).should == @report
      end
    end
  end

  describe 'when asked to set default options when no options specified' do
    before do
      @profile = Profile.new :profile_id=>123
    end
    def self.it_should_default option, value, report=nil
      options = report ? %Q|{:report=>"#{report}"}| : '{}'
      eval %Q|it 'should set :#{option} to #{value}' do
                @profile.set_default_options(#{options})[:#{option}].should == #{value}
              end|
    end
    it_should_default :report, '"Dashboard"'
    it_should_default :tab, '0'
    it_should_default :format, 'Rugalytics::FORMAT_CSV'
    it_should_default :rows, '50'
    it_should_default :offset, '0'
    it_should_default :compute, '"average"'
    it_should_default :gdfmt, '"nth_day"'
    it_should_default :view, '0'

    it_should_default :tab, 'nil', 'GeoMap'
    it_should_default :rows, 'nil', 'GeoMap'
    it_should_default :gdfmt, 'nil', 'GeoMap'

    it 'should default :from to a month ago, and :to to today' do
      @month_ago = mock('month_ago')
      @today = mock('today')
      @profile.should_receive(:a_month_ago).and_return @month_ago
      @profile.should_receive(:today).and_return @today
      @profile.should_receive(:ensure_datetime_in_google_format).with(@month_ago).and_return @month_ago
      @profile.should_receive(:ensure_datetime_in_google_format).with(@today).and_return @today
      options = @profile.set_default_options({})
      options[:from].should == @month_ago
      options[:to].should == @today
    end
  end

  describe 'when asked to convert option keys to uri parameter keys' do
    before do
      @profile = Profile.new :profile_id=>123
    end
    def self.it_should_convert option_key, param_key, value_addition=''
      eval %Q|it 'should convert :#{option_key} to :#{param_key}' do
                params = @profile.convert_options_to_uri_params({:#{option_key} => 'value'})
                params[:#{param_key}].should == 'value#{value_addition}'
              end|
    end
    it_should_convert :report,  :rpt, 'Report'
    it_should_convert :compute, :cmp
    it_should_convert :format,  :fmt
    it_should_convert :view,    :view
    it_should_convert :rows,    :trows
    it_should_convert :offset,  :tst
    it_should_convert :gdfmt,   :gdfmt
    it_should_convert :url,     :d1
    it_should_convert :page_title,:d1

    it 'should convert from and to dates into the period param' do
      from = '20080801'
      to = '20080808'
      params = @profile.convert_options_to_uri_params :from=>from, :to=>to
      params[:pdr].should == "#{from}-#{to}"
    end
    it 'should set param id to be the profile id' do
      @profile.convert_options_to_uri_params({})[:id].should == 123
    end
  end

  it "should be able to find all profiles for an account" do
    html = fixture('analytics_profile_find_all.html')
    Profile.should_receive(:get).and_return(html)
    accounts = Profile.find_all('1254221')
    accounts.collect(&:name).should ==  ["blog.your_site.com"]
  end

  describe "finding by account name and profile name" do
    it 'should find account and find profile' do
      account_name = 'your_site.com'
      profile_name = 'blog.your_site.com'
      account = mock('account')
      profile = mock('profile')

      Account.should_receive(:find).with(account_name).and_return account
      account.should_receive(:find_profile).with(profile_name).and_return profile
      Profile.find(account_name, profile_name).should == profile
    end
  end

  describe "finding a profile by passing single name when account and profile name are the same" do
    it 'should find account and find profile' do
      name = 'your_site.com'
      account = mock('account')
      profile = mock('profile')

      Account.should_receive(:find).with(name).and_return account
      account.should_receive(:find_profile).with(name).and_return profile
      Profile.find(name).should == profile
    end
  end
end