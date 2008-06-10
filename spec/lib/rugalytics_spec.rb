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

  describe 'when RAILS_ROOT is nil' do
    it 'should not call rails_setup method' do
      Rugalytics.should_not_receive(:rails_setup)
      load(File.dirname(__FILE__) + '/../../lib/rugalytics.rb')
    end
  end

  describe 'when RAILS_ROOT is defined and not nil' do
    # it 'should call rails_setup method' do
      # RAILS_ROOT = '.'
      # Rugalytics.should_receive(:rails_setup).with(RAILS_ROOT)
      # load(File.dirname(__FILE__) + '/../../lib/rugalytics.rb')
      # RAILS_ROOT = nil
    # end

    before do
      @rails_root = '.'
      @config_file = "#{@rails_root}/config/rugalytics.yml"
    end

    it 'should look for rugalytics.yml file' do
      File.should_receive(:exist?).with(@config_file).and_return false
      Rugalytics.rails_setup(@rails_root)
    end

    describe 'and config/rugalytics.yml is present' do
      before do
        File.stub!(:exist?).with(@config_file).and_return true
      end

      it 'should load config' do
        Rugalytics.should_receive(:load_config).with(@config_file).and_return Hash.new
        Rugalytics.rails_setup(@rails_root)
      end

      it 'should save username and password if in credentials' do
        user = 'user'
        password = 'password'
        Rugalytics.stub!(:load_config).and_return :username => user, :password => password
        Rugalytics.should_receive(:username=).with(user)
        Rugalytics.should_receive(:password=).with(password)
        Rugalytics.rails_setup(@rails_root)
      end

      it 'should save profile if in credentials' do
        profile = 'profile'
        account = 'account'
        Rugalytics.stub!(:load_config).and_return :profile => profile, :account => account
        Rugalytics.should_receive(:account=).with(account)
        Rugalytics.should_receive(:profile=).with(profile)
        Rugalytics.rails_setup(@rails_root)
      end

      it 'should load config file using Yaml' do
        file = 'file'
        YAML.should_receive(:load_file).with(file)
        Rugalytics.load_config(file)
      end
    end
  end

end