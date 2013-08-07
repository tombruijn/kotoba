require "spec_helper"

describe Kotoba::Export::Document do
  let(:document) { Kotoba::Export::Document.new(Kotoba.config.to_h) }
  before :all do
    Kotoba.config do |c|
      c.layout do |l|
        l.width = 10.cm
        l.height = 20.cm
        l.margin do |m|
          m.top = 1.cm
          m.bottom = 2.cm
          m.outer = 3.cm
          m.inner = 4.cm
        end
      end
    end
  end

  describe ".header_top_position" do
    subject { document.send(:header_top_position) }

    it { should == 17.cm }
  end

  describe ".footer_top_position" do
    subject { document.send(:footer_top_position) }

    it { should == 2.cm }
  end

  describe ".left_position" do
    subject { document.send(:left_position) }

    context "on odd page number" do
      before { document.stub(:page_number => 1) }

      it "should left align based on default location of page" do
        should == 4.cm
      end
    end

    context "on even page number" do
      before { document.stub(:page_number => 2) }

      it "should left align based on difference in inner and outer margin" do
        should == 3.cm
      end
    end
  end
end
