require 'yaml'
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
      @profile = Rugalytics.default_profile

      server = HTTPServer.new :Port => 8888

      server.mount("/", Rugalytics::Servlet)

      server.mount_proc("/top_content_detail_keywords") {|request, response|
        url = request.query['url']
        report = @profile.top_content_detail_keywords_report(:url => url)
        response.body = [url, report.name, report.items.to_yaml].join("\n")
        response['Content-Type'] = "text/plain"
      }

      trap("INT"){ server.shutdown }
      server.start
    end
  end
end
