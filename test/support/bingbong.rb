class BingBong
  attr_reader :frames, :frame, :methods

  def initialize
    @methods = []
  end

  def bing; bong; end
  def bong; bang; end
  def bang; Pry.start(binding); end
end
