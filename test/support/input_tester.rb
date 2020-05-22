class InputTester
  def initialize(*actions)
    if actions.last.is_a?(Hash) && actions.last.keys == [:history]
      @hist = actions.pop[:history]
    end
    @orig_actions = actions.dup
    @actions = actions
  end

  def readline(*)
    @actions.shift.tap{ |line| @hist << line if @hist }
  end

  def rewind
    @actions = @orig_actions.dup
  end
end
