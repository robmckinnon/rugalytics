require 'webrick'
include WEBrick

module Rugalytics

  class Servlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      res.body = "<HTML>hello, world.</HTML>"
      res['Content-Type'] = "text/html"
    end
  end

  class Server
    def initialize
      begin
        require 'webrick'
        self.class.send(:include, WEBrick)
      rescue LoadError
        puts "You need to have webrick installed to run a rugalytics server"
      end

      @profile = Rugalytics.default_profile
      @reports = {}

      server = HTTPServer.new :Port => 8888

      server.mount("/", Rugalytics::Servlet)

      server.mount_proc("/top_content_detail_keywords") {|request, response|
        url = request.query['url']
        @reports[url] ||= @profile.top_content_detail_keywords_report(:url => url)
        items = @reports[url].items
        data = {:url =>url, :report_name=>@reports[url].name, :items=>items}
        response.body = data.to_json
        response['Content-Type'] = "application/json"
      }

      trap("INT"){ server.shutdown }
      server.start
    end
  end
end
