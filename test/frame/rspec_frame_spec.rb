require "pry-stack_explorer/frame"

RSpec.describe PryStackExplorer::Frame::RSpecFrame do
  it "shows the example description" do
    frame = described_class.new(binding)
    expect(frame.description).to eq('it "shows the example description"')
    expect(frame.sig).to eq("PryStackExplorer::Frame::RSpecFrame")
  end

  it do # anonymous
    frame = described_class.new(binding)
    expect(frame.description).to eq("it (anonymous)")
  end

  context "info line" do
    it "includes the describe path in sig" do
      frame = described_class.new(binding)
      expect(frame.info).to include("RSpecFrame")
    end
  end
end
