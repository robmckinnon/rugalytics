require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rugalytics do

  describe "finding a profile by its account name and profile name" do
    it 'should return the match' do
      account_name = 'your_site.com'
      profile_name = 'blog.your_site.com'
      profile = mock('profile')
      Rugalytics::Profile.should_receive(:find).with(account_name, profile_name).and_return profile
      Rugalytics::find_profile(account_name, profile_name).should == profile
    end
  end

  describe "finding a profile by its account_id and profile_id" do
    it 'should return the match' do
      account_id = 1254221
      profile_id = 12341234
      profile = mock('profile')
      Rugalytics::Profile.should_receive(:find).with(account_id, profile_id).and_return profile
      Rugalytics::find_profile(account_id, profile_id).should == profile
    end
  end

  describe "finding a profile by passing single name when account and profile name are the same" do
    it 'should return the match' do
      name = 'your_site.com'
      profile = mock('profile')
      Rugalytics::Profile.should_receive(:find).with(name, nil).and_return profile
      Rugalytics::find_profile(name).should == profile
    end
  end

end