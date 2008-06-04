require 'net/https'

module Rugalytics
  class Connection
    def initialize(base_url, args = {})
      @base_url = base_url
      @username = args[:username]
      @password = args[:password]
    end

    def get(resource, args = nil)
      request(resource, "get", args)
    end

    def post(resource, args = nil)
      request(resource, "post", args)
    end

    def request(resource, method = "get", args = nil)
      url = URI.join(@base_url, resource)
      url.query = args.map { |k,v| "%s=%s" % [URI.encode(k.to_s), URI.encode(v.to_s)] }.join("&") if args

      case method
      when "get"
        req = Net::HTTP::Get.new(url.request_uri)
      when "post"
        req = Net::HTTP::Post.new(url.request_uri)
      end

      req.basic_auth(@username, @password) if @username && @password

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.port == 443)

      res = http.start() { |conn| conn.request(req) }
      res.body
    end
  end
end