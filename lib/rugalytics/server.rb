require 'rack'

module Rugalytics
  class Server
    def initialize
      @profile = Rugalytics.default_profile
      @reports = {}
      Rack::Handler::WEBrick.run(self, :Port=>8888)
    end

    def call(env)
      path = env['PATH_INFO']
      request = Rack::Request.new(env)
      report = (path.tr('/','')+'_report').to_sym
      send_data(report, request.GET.symbolize_keys)
    end

    def send_data report, params
      key = (params.values << report).join('')
      @reports[key] ||= @profile.send(report, params)
      report = @reports[key]
      data = params.merge({:report_name => report.name, :items => report.items})
      [200, {'Content-Type' => "application/json"}, data.to_json ]
    end
  end
end
