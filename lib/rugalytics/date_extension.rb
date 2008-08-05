class Date

  def self.i18n_parse text
    if text.include? '年'
      text = text.sub('年','-')
      text = text.sub('月','-')
      text = text.sub('日','')
    end
    begin
      Date.parse(text)
    rescue Exception => e
      raise "#{e}: #{text}"
    end
  end

end