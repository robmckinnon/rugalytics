module Rugalytics
  class Profile < ::Google::Base

    class << self
      def find_all(account_id)
        doc = Hpricot::XML get("https://www.google.com:443/analytics/home/admin?scid=#{account_id}")
        (doc/'select[@name=profile_list] option').inject([]) do |profiles, option|
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

    def load_report(name, options={})
      report = Rugalytics::Report.new report(options.merge({:report=>name}))
      puts report.attributes
      report
    end

    def report(options={})
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
      # https://www.google.com/analytics/reporting/export?fmt=2&id=1712313&pdr=20080504-20080603&cmp=average&&rpt=PageviewsReport
      self.class.get("https://google.com/analytics/reporting/export", :query_hash => params)
    end

    def pageviews(options={})
      load_report('Pageviews',options).page_views_total
    end

    def pageviews_by_day(options={})
      load_report('Pageviews',options).page_views_by_day
    end

    def visits(options={})
      load_report('Visits',options).visits_total
    end

    def visits_by_day(options={})
      load_report('Visits',options).visits_by_day
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
      def get_item_summary_by_message(options={})
        raise ArgumentError unless options.has_key?(:message)
        message = options.delete(:message).to_s.capitalize
        response = report(options.merge({:report => 'Dashboard'}))
        doc = Hpricot::XML(response)
        pageviews = (doc/:ItemSummary).detect { |summary| summary.at('Message').inner_html == message }
        pageviews && pageviews.at('SummaryValue') ? pageviews.at('SummaryValue').inner_html.gsub(/\D/, '').to_i : 0
      end

      def get_serie_by_label(options={})
        raise ArgumentError unless options.has_key?(:label)
        label = options.delete(:label).to_s.capitalize
        response = report(options.merge({:report => 'Dashboard'}))
        doc = Hpricot::XML(response)
        serie = (doc/:Serie).detect { |serie| serie.at('Label').inner_html == label }
        if serie
          (serie/:Point).inject([]) { |collection, point| collection << [Date.parse(point.at('Label').inner_html), point.at('Value').inner_html.to_i] }
        else
          []
        end
      end
  end
end