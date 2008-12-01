require 'rack'

module Rugalytics
  class Server
    def initialize
      @profile = Rugalytics.default_profile
      @reports = {}
      Rack::Handler::WEBrick.run(self, :Port=>8888)
    end

    def call(env)
      path = env['PATH_INFO'].tr('/','')
      request = Rack::Request.new(env)
      report_name = (path + '_report').to_sym
      send_data(report_name, request.GET.symbolize_keys)
    end

    def send_data report_name, params
      key = (params.values << report_name).join('')
      @reports[key] ||= @profile.send(report_name, params)
      report = @reports[key]
      json = report.attributes.to_json
      json = add_in_front params, json
      json = add_in_front({:report_name => report.name}, json)

      [200, {'Content-Type' => "application/json"}, json ]
    end

    private
      def add_in_front hash, json
        json.sub('{', hash.to_json.chomp("}") + ', ' )
      end
  end
end
