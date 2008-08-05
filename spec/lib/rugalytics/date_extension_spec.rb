require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Date do
  describe 'when parsing Japanese formatted date' do
    it 'should parse correctly' do
      Date.i18n_parse('2008年7月29日').should == Date.new(2008,7,29)
    end
  end
end