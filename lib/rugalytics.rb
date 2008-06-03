require 'net/http'
require 'net/https'
require 'uri'
require 'ostruct'
require 'rubygems'
require 'hpricot'
require 'activesupport'
require 'google/base'

module Rugalytics
  VERSION = "0.0.1"

  FORMAT_PDF = '0' unless defined? FORMAT_PDF
  FORMAT_XML = '1' unless defined? FORMAT_XML
  FORMAT_CSV = '2' unless defined? FORMAT_CSV
  FORMAT_TAB = '3' unless defined? FORMAT_TAB

  VALID_REPORTS = %w[ Dashboard ] unless defined? VALID_REPORTS

  class InvalidCredentials < Exception
  end

  def self.login username, password
    Google::Base.establish_connection(username, password)
  end

  def self.find_profile account_id_or_name, profile_id_or_name=nil
    begin
      Profile.find account_id_or_name, profile_id_or_name
    rescue NameError => e
      raise 'No connection - call Rugalytics.login(<username>,<password>)'
    end
  end
end

require File.dirname(__FILE__) + '/rugalytics/connection'
require File.dirname(__FILE__) + '/rugalytics/account'
require File.dirname(__FILE__) + '/rugalytics/profile'