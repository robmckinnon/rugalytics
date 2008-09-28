require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Item, 'when creating' do

  before :all do
    @url = 'theyworkforyou.co.nz'
    @attributes = 'Page,Page Views,Unique Page Views,Time on Page,Bounce Rate,% Exit,$ Index'
    @values = '/,189,157,54.94957983193277,0.4862385392189026,0.37037035822868347,0.0'
  end

  it "it should create fields for attributes and values" do
    item = Rugalytics::Item.new @attributes.split(','), @values.split(','), @url

    item.url.should == 'http://theyworkforyou.co.nz/'
    item.path.should == '/'
    item.pageviews.should == '189'
    item.unique_pageviews.should == '157'
    item.time_on_page.should == '54.94957983193277'
    item.bounce_rate.should == '0.4862385392189026'
    item.percentage_exit.should == '0.37037035822868347'
    item.dollar_index.should == '0.0'
  end

end