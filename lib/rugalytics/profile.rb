module Rugalytics
  class Profile < ::Google::Base

    class << self
      def find_all(account_id)
        doc = Hpricot::XML get("https://www.google.com:443/analytics/settings/home?scid=#{account_id}")
        (doc/'select[@id=profile] option').inject([]) do |profiles, option|
          profile_id = option['value'].to_i
          profiles << Profile.new(:account_id => account_id, :profile_id => profile_id, :name => option.inner_html) if profile_id > 0
          profiles
        end
      end

      def find(account_id_or_name, profile_id_or_name=nil)
        profile_id_or_name = account_id_or_name unless profile_id_or_name
        account = Account.find(account_id_or_name)
        account ? account.find_profile(profile_id_or_name) : nil
      end
    end

    attr_accessor :account_id, :name, :profile_id

    def initialize(attrs)
      raise ArgumentError, ":profile_id is required" unless attrs.has_key?(:profile_id)
      @account_id = attrs[:account_id]  if attrs.has_key?(:account_id)
      @name       = attrs[:name]        if attrs.has_key?(:name)
      @profile_id = attrs[:profile_id]  if attrs.has_key?(:profile_id)
    end

    def method_missing symbol, *args
      if name = symbol.to_s[/^(.+)_report$/, 1]
        options = args && args.size == 1 ? args[0] : {}
        create_report(name.camelize, options)
      else
        super
      end
    end

    def load_report(name, options={})
      if options=={}
        ActiveSupport::Deprecation.warn "Profile#load_report('#{name}') has been deprecated, use Profile##{name.tableize}_report instead"
      else
        ActiveSupport::Deprecation.warn "Profile#load_report('#{name}',options) has been deprecated, use Profile##{name.tableize}_report(options) instead"
      end
      create_report(name, options={})
    end

    def get_report_csv(options={})
      options.reverse_merge!({
        :report  => 'Dashboard',
        :from    => Time.now.utc - 7.days,
        :to      => Time.now.utc,
        :tab     => 0,
        :format  => FORMAT_CSV,
        :rows    => 50,
        :compute => 'average',
        :gdfmt   => 'nth_day',
        :view    => 0
      })
      options[:from] = ensure_datetime_in_google_format(options[:from])
      options[:to]   = ensure_datetime_in_google_format(options[:to])

      params = {
        :pdr  => "#{options[:from]}-#{options[:to]}",
        :rpt  => "#{options[:report]}Report",
        :cmp  => options[:compute],
        :fmt  => options[:format],
        :view => options[:view],
        :tab  => options[:tab],
        :trows=> options[:rows],
        :gdfmt=> options[:gdfmt],
        :id   => profile_id,
      }
      puts params.inspect
      # https://www.google.com/analytics/reporting/export?fmt=2&id=1712313&pdr=20080701-20080731&cmp=average&&rpt=PageviewsReport
      self.class.get("https://google.com/analytics/reporting/export", :query_hash => params)
    end

    def pageviews(options={})
      pageviews_report(options).page_views_total
    end

    def pageviews_by_day(options={})
      pageviews_report(options).page_views_by_day
    end

    def visits(options={})
      visits_report(options).visits_total
    end

    def visits_by_day(options={})
      visits_report(options).visits_by_day
    end

    # takes a Date, Time or String
    def ensure_datetime_in_google_format(time)
      time = Date.parse(time) if time.is_a?(String)
      time.is_a?(Time) || time.is_a?(Date) ? time.strftime('%Y%m%d') : time
    end

    def to_s
      "#{name} (#{profile_id})"
    end

    private

      def create_report(name, options={})
        report = Rugalytics::Report.new get_report_csv(options.merge({:report=>name}))
        puts report.attribute_names
        report
      end
  end
end