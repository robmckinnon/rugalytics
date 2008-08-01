module Rugalytics
  class Account < ::Google::Base

    class << self
      def find_all
        doc = Hpricot::XML get('https://www.google.com:443/analytics/settings/')
        (doc/'select[@id=account] option').inject([]) do |accounts, option|
          account_id = option['value'].to_i
          accounts << new(:account_id => account_id, :name => option.inner_html) if account_id > 0
          accounts
        end
      end

      def find account_id_or_name
        matchs = find_all.select{|a| a.name == account_id_or_name || a.account_id.to_s == account_id_or_name.to_s }
        matchs.empty? ? nil : matchs.first
      end
    end

    attr_accessor :name, :account_id

    def initialize(attrs)
      @name = attrs[:name]
      @account_id = attrs[:account_id]
    end

    def profiles(force=false)
      if force || @profiles.nil?
        @profiles = Profile.find_all(account_id)
      end
      @profiles
    end

    def find_profile profile_id_or_name
      profiles.detect { |p| p.profile_id.to_s == profile_id_or_name.to_s || p.name == profile_id_or_name }
    end

    def to_s
      "#{name} (#{account_id})"
    end
  end
end