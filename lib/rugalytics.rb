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

# See README for usage documentation.
module Rugalytics
  VERSION = "0.0.2"

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

    def rails_setup rails_root
      config_file = "#{rails_root}/config/rugalytics.yml"
      if File.exist? config_file
        config = load_config(config_file)
        self.username= config[:username] if config[:username]
        self.password= config[:password] if config[:password]
        self.account= config[:account] if config[:account]
        self.profile= config[:profile] if config[:profile]
      end
    end

    def load_config filename
      YAML.load_file(filename)
    end

    def user= name
      @user = name
    end

    def password= name
      @password = name
    end

    def account= name
      @account = name
    end

    def profile= name
      @password = name
    end
  end
end

require File.dirname(__FILE__) + '/rugalytics/connection'
require File.dirname(__FILE__) + '/rugalytics/account'
require File.dirname(__FILE__) + '/rugalytics/profile'
require File.dirname(__FILE__) + '/rugalytics/report'
require File.dirname(__FILE__) + '/rugalytics/item'
require File.dirname(__FILE__) + '/rugalytics/graph'

Rugalytics.rails_setup(RAILS_ROOT) if defined?(RAILS_ROOT) && RAILS_ROOT