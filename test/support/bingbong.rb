class BingBong
  attr_reader :frames, :frame

  def bing; bong; end
  def bong; bang; end
  def bang; Pry.start(binding); end
end
