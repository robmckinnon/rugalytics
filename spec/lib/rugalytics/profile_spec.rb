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

  describe 'finding pageviews' do
    before do
      @profile = Profile.new :profile_id=>123
      @report = mock('report',:page_views_total=>100)
    end
    it 'should return total from loaded "Pageviews" report' do
      @profile.should_receive(:pageviews_report).with({}).and_return @report
      @profile.pageviews.should == @report.page_views_total
    end
    describe 'when from and to dates are specified' do
      it 'should return total from "Pageviews" report for given dates' do
        options = {:from=>'2008-05-01', :to=>'2008-05-03'}
        @profile.should_receive(:pageviews_report).with(options).and_return @report
        @profile.pageviews(options).should == @report.page_views_total
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