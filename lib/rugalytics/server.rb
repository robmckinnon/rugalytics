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

      if path.empty?
        html = %Q|
        <h1>Rugalytics on Rugrat</h1>
        <p>TO INSTALL:</p>
        <p>Add Greasemonkey to Firefox: <a href="https://addons.mozilla.org/firefox/748/">https://addons.mozilla.org/firefox/748/</a></p>
        <p>Add rugrat user script: <a href="http://localhost:8888/rugrat.user.js">rugrat.user.js</a></p>
        <p>Configure site for rugrat to run on:</p>
        <p><code>Tools -&gt; Greasemonkey -&gt; Manage User Scripts</code><br/>
        <code>-&gt; select rugrat -&gt; press "Add" -&gt; add your site, e.g. http://your_site.com/* -&gt; press "Close"</code></p>
        <p>Create a rugalytics.yml config file containing:</p><pre>
---
account: your_account_name
profile: your_profile_name
username: your_user_name
password: your_pass_w

</pre>
        <p>Run rugalytics on console in same directory as rugalytics.yml:</p>
        <p><code>&gt; rugalytics</code></p>
        <p>Browse your site!</p>|
        [200, {'Content-Type' => "text/html"}, html]
      elsif path == 'rugrat.user.js'
        [200, {'Content-Type' => "application/json"}, File.new(File.dirname(__FILE__)+'/rugrat.user.js').readlines ]
      else
        request = Rack::Request.new(env)
        report_name = (path + '_report').to_sym
        send_data(report_name, request.GET.symbolize_keys)
      end
    end

    def send_data report_name, params
      key = (params.values << report_name).join('')
      @reports[key] ||= @profile.send(report_name, params)
      report = @reports[key]

      json = report.attributes.to_json
      add_in_front params, json
      report.attribute_names.each do |name|
        if name[/(.*)pageviews_graph/]
          total = "#{$1}pageviews_total".to_sym
          add_in_front({total => report.send(total)}, json)
        end
      end
      add_in_front({:report_name => report.name}, json)

      [200, {'Content-Type' => "application/json"}, json ]
    end

    private
      def add_in_front hash, json
        json.sub!('{', hash.to_json.chomp("}") + ', ' ) unless hash.empty?
      end
  end
end
