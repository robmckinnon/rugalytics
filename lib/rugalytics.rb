# coding:utf-8
require 'net/http'
require 'net/https'
require 'uri'
require 'ostruct'
require 'rubygems'
require 'hpricot'
require 'activesupport'
require 'google/base'
require 'morph'
require 'yaml'

if RUBY_VERSION < "1.9"
  require 'fastercsv'
else
  require 'csv'
end

# See README for usage documentation.
module Rugalytics
  VERSION = "0.2.0"

  FORMAT_PDF = '0' unless defined? FORMAT_PDF
  FORMAT_XML = '1' unless defined? FORMAT_XML
  FORMAT_CSV = '2' unless defined? FORMAT_CSV
  FORMAT_TAB = '3' unless defined? FORMAT_TAB

  VALID_REPORTS = %w[ Dashboard ] unless defined? VALID_REPORTS

  module MorphLessMethodMissing
    def self.included(base)
      base.extend Morph::ClassMethods
      base.send(:include, Morph::InstanceMethods)
    end
  end

  class InvalidCredentials < Exception
  end

  class << self
    def login username, password
      Google::Base.establish_connection(username, password)
    end

    def find_profile account_id_or_name, profile_id_or_name=nil
      begin
        Profile.find account_id_or_name, profile_id_or_name
      rescue NameError => e
        raise 'No connection - call Rugalytics.login(<username>,<password>)'
      end
    end

    def reports
      profile = Rugalytics.default_profile
      names = profile.report_names
      puts names
      names.collect {|n| puts ''; puts n; profile.send(n.to_sym)}
    end

    def default_profile
      config_setup '.' unless config
      if config && config.account
        begin
          find_profile config.account, config.profile
        rescue Exception => e
          if e.to_s.include? 'No connection'
            login config.username, config.password if config.username && config.password
            find_profile config.account, config.profile
          end
        end
      end
    end

    def config
      @config
    end

    def config_setup root
      config_file = "#{root}/config/rugalytics.yml"
      config_file = "#{root}/rugalytics.yml" unless File.exist? config_file
      @config = load_config(config_file) if File.exist? config_file
    end

    def load_config filename
      hash = YAML.load_file(filename)
      OpenStruct.new(hash)
    end

    def i18n_date_parse text
      if text.include? '年'
        text = text.sub('年','-')
        text = text.sub('月','-')
        text = text.sub('日','')
      end
      begin
        Date.parse(text)
      rescue Exception => e
        raise "#{e}: #{text}"
      end
    end
  end
end

require File.dirname(__FILE__) + '/rugalytics/connection'
require File.dirname(__FILE__) + '/rugalytics/account'
require File.dirname(__FILE__) + '/rugalytics/profile'
require File.dirname(__FILE__) + '/rugalytics/report'
require File.dirname(__FILE__) + '/rugalytics/item'
require File.dirname(__FILE__) + '/rugalytics/graph'
require File.dirname(__FILE__) + '/rugalytics/server'

# Rugalytics.config_setup(RAILS_ROOT) if defined?(RAILS_ROOT) && RAILS_ROOT

# Rugalytics::Server.new
