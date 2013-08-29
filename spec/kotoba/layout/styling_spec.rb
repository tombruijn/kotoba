require "spec_helper"

describe Kotoba::Layout::Styling do
  subject { @styling }

  context "with styling" do
    before :all do
      @styling = Kotoba::Layout::Styling.new
      @styling.font = "My font"
      @styling.size = 15.pt
      @styling.color = "000000"
      @styling.align = :right
      @styling.direction = :rtl
      @styling.character_spacing = 1.pt
      @styling.line_height = 20.pt
      @styling.style = ["bold", "italic"]
      @styling.indent = 1.cm
      @styling.prefix = "In the beginning"
    end

    its(:font) { should == "My font" }
    its(:size) { should == 15.pt }
    its(:color) { should == "000000" }
    its(:align) { should == :right }
    its(:direction) { should == :rtl }
    its(:character_spacing) { should == 1.pt }
    its(:line_height) { should == 20.pt }
    its(:style) { should == ["bold", "italic"] }
    its(:indent) { should == 1.cm }

    pending "not yet supported" do
      its(:prefix) { should == "In the beginning" }
    end
  end

  describe "without styling, should fall back on default" do
    before(:all) { @styling = Kotoba::Layout::Styling.new }

    its(:font) { should == "Times-Roman" }
    its(:size) { should == 12.pt }
    its(:color) { should == "000000" }
    its(:align) { should == :left }
    its(:direction) { should == :ltr }
    its(:character_spacing) { should == 0 }
    its(:line_height) { should == 12.pt }
    its(:style) { should be_empty }
    its(:indent) { should == 0.mm }

    pending "not yet supported" do
      its(:prefix) { should be_empty }
    end
  end

  pending ".using_prawn_font?"

  describe Kotoba::Layout::DefaultStyling do
    before(:all) { @default = Kotoba::Layout::DefaultStyling.new }
    subject { @default }

    it { should be_kind_of Kotoba::Layout::Styling }
    its(:font) { should == "Times-Roman" }
    its(:size) { should == 12.pt }
    its(:color) { should == "000000" }
    its(:align) { should == :left }
    its(:direction) { should == :ltr }
    its(:character_spacing) { should == 0 }
    its(:line_height) { should == 12.pt }
    its(:style) { should be_empty }
    its(:indent) { should == 0.mm }

    pending "not yet supported" do
      its(:prefix) { should be_empty }
    end
  end
end
