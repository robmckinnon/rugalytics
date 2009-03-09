module Rugalytics
  class Profile < ::Google::Base

    class << self
      def find_all(account_id)
        doc = Hpricot get("https://www.google.com:443/analytics/settings/home?scid=#{account_id}")
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

    def report_names
      unless @report_names
        html = Profile.get("https://www.google.com/analytics/reporting/?scid=#{profile_id}")
        # reports = html.scan(/rpt=([A-Za-z]+)("|&)/)
        reports = html.scan(/changeReport\(&(#39|quot);([a-z_]+)&(#39|quot);/)

        non_report_names = ['goal_intro', 'add_segment', 'customs_overview',
          'manage_emails', 'manage_segments', 'user_defined', 'audio',
          'custom_reports_overview', 'site_search_intro', 'tv']
        names = reports.collect { |name| name[1] } - non_report_names
        more_names = []

        names.each do |name|
          html = Profile.get("https://www.google.com/analytics/reporting/#{name}?id=#{profile_id}")
          reports = html.scan(/changeReport\(&(#39|quot);([a-z_]+)&(#39|quot);/)
          more_names += reports.collect { |name| name[1] }
        end

        names += more_names
        names -= non_report_names
        names = names.collect do |name|
          name = name.sub(/^maps$/,'geo_map').sub(/^sources$/,'traffic_sources')
          name = name.sub(/^visitors$/,'visitors_overview')
          name = name.sub(/^content_detail_(.*)$/,'top_content_detail_\1')
          name = name.sub(/^content_titles$/,'content_by_title')
          "#{name}_report"
        end

        @report_names = names.uniq.sort
      end
      @report_names
    end

    def method_missing symbol, *args
      if name = symbol.to_s[/^(.+)_report$/, 1]
        options = args && args.size == 1 ? args[0] : {}
        create_report(name.camelize, options)
      else
        super
      end
    end

    def get_report_csv(options={})
      options = set_default_options(options)
      params = convert_options_to_uri_params(options)
      self.class.get("https://www.google.com/analytics/reporting/export", :query_hash => params)
    end

    def convert_options_to_uri_params(options)
      params = {
        :pdr  => "#{options[:from]}-#{options[:to]}",
        :rpt  => "#{options[:report]}Report",
        :cmp  => options[:compute],
        :fmt  => options[:format],
        :view => options[:view],
        :tab  => options[:tab],
        :trows=> options[:rows],
        :tst  => options[:offset],
        :gdfmt=> options[:gdfmt],
        :id   => profile_id
      }
      params[:d1] = options[:url] if options[:url]
      params[:d1] = options[:page_title] if options[:page_title]
      if options[:keywords]
        params[:d1] = options[:keywords].gsub(' ','+')
        params[:seg] = '1'
        params[:segkey] = options[:segment] ? options[:segment] : 'organization'
      end
      if options[:value]
        params[:gval] = options[:value]
      end
      params
    end

    def a_month_ago
      Time.now.utc.last_month
    end

    def today
      Time.now.utc
    end

    def set_default_options(options)
      options.reverse_merge!({
        :report  => 'Dashboard',
        :from    => a_month_ago,
        :to      => today,
        :tab     => 0,
        :format  => FORMAT_CSV,
        :rows    => 50,
        :offset  => 0,
        :compute => 'average',
        :gdfmt   => 'nth_day',
        :view    => 0
      })
      if options[:report] == 'GeoMap'
        options.delete(:tab)
        options.delete(:gdfmt)
        options.delete(:rows)
      end
      options[:from] = ensure_datetime_in_google_format(options[:from])
      options[:to]   = ensure_datetime_in_google_format(options[:to])
      options
    end

    # Extract Page Views from Content Drilldown Report URLs.
    # Use with :url => "/projects/68263/" to options hash
    #
    # def drilldown(options={})
      # content_drilldown_report(options).pageviews_total
    # end
    #
    # instead do
    # profile.content_drilldown_report(:url => '/projects/68263/').pageviews_total

    def pageviews(options={})
      pageviews_report(options).pageviews_total
    end

    def pageviews_by_day(options={})
      pageviews_report(options).pageviews_by_day
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
        options = options.merge({:report=>name})
        csv = get_report_csv(options)
        begin
          report = Rugalytics::Report.new csv
          puts report.attribute_names
          report
        rescue Exception => e
          puts convert_options_to_uri_params(options).inspect
          puts csv
          raise e
        end
      end
  end
end
