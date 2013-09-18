require "spec_helper"

describe Kotoba::Layout::Styling do
  describe "new" do
    before :all do
      @styling = Kotoba::Layout::Styling.new(:all, {
        font: "A font",
        size: 19.pt,
        color: "123123",
        align: :center,
        direction: :rtl,
        character_spacing: 10.pt,
        line_height: 30.pt,
        style: ["bold", "italic"],
        indent: 10.cm,
        prefix: "..."
      })
    end
    subject { @styling }

    its(:font) { should == "A font" }
    its(:size) { should == 19.pt }
    its(:color) { should == "123123" }
    its(:align) { should == :center }
    its(:direction) { should == :rtl }
    its(:character_spacing) { should == 10.pt }
    its(:line_height) { should == 30.pt }
    its(:style) { should == ["bold", "italic"] }
    its(:indent) { should == 10.cm }
    its(:prefix) { should == "..." }
  end

  describe "options" do
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
      its(:prefix) { should == "In the beginning" }

      describe ".to_h" do
        subject { @styling.to_h }

        its([:size]) { should == 15.pt }
        its([:color]) { should == "000000" }
        its([:align]) { should == :right }
        its([:direction]) { should == :rtl }
        its([:character_spacing]) { should == 1.pt }
        its([:leading]) { should == 20.pt }
        its([:style]) { should == ["bold", "italic"] }
        its([:indent_paragraphs]) { should == 1.cm }
        its([:prefix]) { should == "In the beginning" }

        context "with known prawn font" do
          before { @styling.font = "Courier" }

          its([:font]) { should == "Courier" }
        end

        context "with custom registered font" do
          before do
            Kotoba.config.add_font "OpenSans", {}
            @styling.font = "OpenSans"
          end

          its([:font]) { should == "OpenSans" }
        end

        context "with unknown font" do
          before { @styling.font = "Unknown font" }

          it { should_not have_key :font }
        end
      end
    end

    describe "without styling, should fall back on default for page" do
      before :all do
        Kotoba.config.layout_for(1..2).default.font = "Courier"
        @styling = Kotoba::Layout::Styling.new(1..2)
      end

      its(:font) { should == "Courier" }
      its(:size) { should == 12.pt }
      its(:color) { should be_empty }
      its(:align) { should == :left }
      its(:direction) { should == :ltr }
      its(:character_spacing) { should == 0 }
      its(:line_height) { should == 12.pt }
      its(:style) { should be_empty }
      its(:indent) { should == 0.mm }
      its(:prefix) { should be_empty }

      describe ".to_h" do
        subject { @styling.to_h }

        its([:font]) { should == "Courier" }
        its([:size]) { should == 12.pt }
        it { should_not have_key :color }
        its([:align]) { should == :left }
        its([:direction]) { should == :ltr }
        it { should_not have_key :character_spacing }
        its([:leading]) { should == 12.pt }
        it { should_not have_key :style }
        its([:indent_paragraphs]) { should == 0.mm }
        it { should_not have_key :prefix }
      end
    end
  end

  describe Kotoba::Layout::DefaultStyling do
    before(:all) { @default = Kotoba::Layout::DefaultStyling.new }
    subject { @default }

    it { should be_kind_of Kotoba::Layout::Styling }
    its(:font) { should == "Times-Roman" }
    its(:size) { should == 12.pt }
    its(:color) { should be_empty }
    its(:align) { should == :left }
    its(:direction) { should == :ltr }
    its(:character_spacing) { should == 0 }
    its(:line_height) { should == 12.pt }
    its(:style) { should be_empty }
    its(:indent) { should == 0.mm }
    its(:prefix) { should be_empty }
  end
end
