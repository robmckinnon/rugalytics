require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rugalytics do

  describe "finding a profile" do

    describe "by its account name and profile name" do
      it 'should return the match' do
        account_name = 'your_site.com'
        profile_name = 'blog.your_site.com'
        profile = mock('profile')
        Rugalytics::Profile.should_receive(:find).with(account_name, profile_name).and_return profile
        Rugalytics::find_profile(account_name, profile_name).should == profile
      end
    end

    describe "by its account_id and profile_id" do
      it 'should return the match' do
        account_id = 1254221
        profile_id = 12341234
        profile = mock('profile')
        Rugalytics::Profile.should_receive(:find).with(account_id, profile_id).and_return profile
        Rugalytics::find_profile(account_id, profile_id).should == profile
      end
    end

    describe "by passing single name when account and profile name are the same" do
      it 'should return the match' do
        name = 'your_site.com'
        profile = mock('profile')
        Rugalytics::Profile.should_receive(:find).with(name, nil).and_return profile
        Rugalytics::find_profile(name).should == profile
      end
    end
  end

  describe 'when RAILS_ROOT is nil' do

    it 'should not call config_setup method' do
      Rugalytics.should_not_receive(:config_setup)
      load(File.dirname(__FILE__) + '/../../lib/rugalytics.rb')
    end
  end

  describe 'when RAILS_ROOT is defined and not nil' do

    before do
      @rails_root = '.'
      @config_file = "#{@rails_root}/config/rugalytics.yml"
      @alt_config_file = "#{@rails_root}/rugalytics.yml"
    end

    it 'should look for rugalytics.yml file' do
      File.should_receive(:exist?).with(@config_file).and_return false
      File.should_receive(:exist?).with(@alt_config_file).and_return false
      Rugalytics.config_setup(@rails_root)
    end

    describe 'and config/rugalytics.yml is present' do
      before do
        File.stub!(:exist?).with(@config_file).and_return true
      end

      it 'should load config' do
        Rugalytics.should_receive(:load_config).with(@config_file).and_return mock('config')
        Rugalytics.config_setup(@rails_root)
      end

      it 'should save username and password if in credentials' do
        user = 'user'
        password = 'password'
        Rugalytics.stub!(:load_config).and_return OpenStruct.new({:username => user, :password => password})
        Rugalytics.config_setup(@rails_root)
        Rugalytics.config.username.should == user
        Rugalytics.config.password.should == password
      end

      it 'should save profile if in credentials' do
        profile = 'profile'
        account = 'account'
        Rugalytics.stub!(:load_config).and_return OpenStruct.new({:profile => profile, :account => account})
        Rugalytics.config_setup(@rails_root)
        Rugalytics.config.account.should == account
        Rugalytics.config.profile.should == profile
      end

      it 'should load config file using Yaml' do
        file = 'file'
        hash = mock('hash')
        YAML.should_receive(:load_file).with(file).and_return hash
        OpenStruct.should_receive(:new).with(hash)
        Rugalytics.load_config(file)
      end

    # it 'should call config_setup method' do
      # RAILS_ROOT = '.'
      # Rugalytics.should_receive(:config_setup).with(RAILS_ROOT)
      # load(File.dirname(__FILE__) + '/../../lib/rugalytics.rb')
      # RAILS_ROOT = nil
    # end

    end
  end

  describe "finding default profile when config has been set" do
    it 'should find profile using config' do
      profile = mock('profile')
      profile_name = 'profile'
      account = 'account'
      Rugalytics.stub!(:config).and_return mock('config', :account=>account, :profile=>profile_name)
      Rugalytics.should_receive(:find_profile).with(account,profile_name).and_return profile
      Rugalytics.default_profile.should == profile
    end
  end
  describe 'when parsing Japanese formatted date' do
    it 'should parse correctly' do
      Rugalytics.i18n_date_parse('2008年7月29日').should == Date.new(2008,7,29)
    end
  end
end