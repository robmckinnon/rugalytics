require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Account do

  describe "being initialized" do
    it "should accept :name as key" do
      a = Rugalytics::Account.new(:name => 'test')
      a.name.should == 'test'
    end

    it "should accept :account_id as key" do
      a = Rugalytics::Account.new(:account_id => '12341234')
      a.account_id.should == '12341234'
    end
  end

  it "should be able to find all accounts for user" do
    html = fixture('analytics_account_find_all.html')
    Rugalytics::Account.should_receive(:get).and_return(html)
    accounts = Rugalytics::Account.find_all
    accounts.collect(&:name).should == %w[your_site.com another_site.com]
    accounts.collect(&:account_id).should == %w[1254221 344381].map(&:to_i)
  end

  it "should be able to find profiles for an account" do
    html = fixture('analytics_profile_find_all.html')
    Rugalytics::Profile.should_receive(:get).and_return(html)
    profiles = Rugalytics::Account.new(:name => 'your_site.com', :account_id => '1254221').profiles
    profiles.collect(&:name).should == ["blog.your_site.com"]
  end

  it "should print kind of pretty" do
    account = Rugalytics::Account.new(:name => 'your_site.com', :account_id => '1254221')
    account.to_s.should == "your_site.com (1254221)"
  end

  before do
    @account = mock('account', :name=>'your_site.com', :account_id=>1254221)
  end

  describe "finding an account by its name" do
    it 'should find all and return the match' do
      Rugalytics::Account.should_receive(:find_all).and_return [@account]
      Rugalytics::Account.find(@account.name).should == @account
    end

    it 'should return nil if there is no match' do
      Rugalytics::Account.should_receive(:find_all).and_return [@account]
      Rugalytics::Account.find('no_match').should be_nil
    end
  end

  describe "finding an account by its account_id" do
    it 'should find all and return the match' do
      Rugalytics::Account.should_receive(:find_all).and_return [@account]
      Rugalytics::Account.find(@account.account_id).should == @account
    end

    it 'should return nil if there is no match' do
      Rugalytics::Account.should_receive(:find_all).and_return [@account]
      Rugalytics::Account.find(111).should be_nil
    end
  end

  describe "finding a profile by its profile_id" do

    it 'should return the match' do
      profile_id = 12341234
      profile = mock('profile', :profile_id => profile_id)
      account = Rugalytics::Account.new({})
      account.should_receive(:profiles).and_return [profile]
      account.find_profile(profile_id).should == profile
    end
  end

  describe "finding a profile by its profile_id" do
    it 'should return the match' do
      profile_id = 12341234
      name = 'blog.your_site.com'
      profile = mock('profile', :profile_id => profile_id, :name => name)
      account = Rugalytics::Account.new({})
      account.should_receive(:profiles).and_return [profile]
      account.find_profile(name).should == profile
    end
  end
end