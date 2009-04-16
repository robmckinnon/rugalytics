require 'rubygems'; require 'spec'; require 'lib/rugalytics'

begin
  require 'echoe'

  Echoe.new("rugalytics", Rugalytics::VERSION) do |m|
    m.author = ["Rob McKinnon"]
    m.email = ["rob ~@nospam@~ rubyforge.org"]
    m.description = File.readlines("README").first
    m.rubyforge_name = "rugalytics"
    m.rdoc_options << '--inline-source'
    m.rdoc_pattern = ["README", "CHANGELOG", "LICENSE"]
    m.dependencies = ["hpricot >=0.6", "activesupport >=2.0.2", "googlebase >=0.2.0", "morph >=0.2.7", "fastercsv >=1.4.0", "rack >=0.4.0"]
    m.executable_pattern = 'bin/rugalytics'
  end

rescue LoadError
  puts "You need to install the echoe gem to perform meta operations on this gem"
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/rugalytics.rb"
end

desc "Run all examples with RCov"
task :rcov do
  sh '/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -Ilib -S rcov --text-report  -o "coverage" -x "Library" spec/lib/**/*'
end