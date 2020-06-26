module IOUtils
  def redirect_pry_output!
    @pry_output = StringIO.new
    Pry.config.output = @pry_output
  end

  attr_accessor :pry_output

  # Set I/O streams.
  #
  # Out defaults to an anonymous StringIO.
  def with_pry_output_captured(new_in, new_out = StringIO.new)
    old_in = Pry.input
    old_out = Pry.output

    Pry.input = new_in
    Pry.output = new_out

    begin
      yield
    ensure
      Pry.input = old_in
      Pry.output = old_out
    end

    new_out
  end

  alias :redirect_pry_io :with_pry_output_captured


  def mock_pry(*args)
    binding = args.first.is_a?(Binding) ? args.shift : binding()

    input = InputTester.new(*args)
    output = StringIO.new

    redirect_pry_io(input, output) do
      binding.pry
    end

    output.string
  end

  def issue_pry_commands(*commands, &block)
    input_tester = InputTester.new(*commands)
    redirect_pry_io(input_tester, &block).string
  end
end
