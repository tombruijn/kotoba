require "spec_helper"

describe Kotoba::Book do
  describe "#new" do
    subject { Kotoba::Book.new }

    its(:parser) { should be_instance_of Kotoba::Parser }
  end

  describe ".load" do
    it "should call the parser collect method" do
      parser = mock
      Kotoba::Parser.should_receive(:new).and_return(parser)
      parser.should_receive(:collect)
    end

    after { Kotoba::Book.new }
  end
end
