require "spec_helper"

describe Kotoba::Layout do
  let(:layout) { Kotoba::Layout.new }

  describe ".to_h" do
    before do
      layout.margin.top = 10.cm
      layout.margin.bottom = 5.cm
      layout.orientation = :landscape
      layout.width = 50.cm
      layout.height = 70.cm
    end
    subject { layout.to_h }

    it "should return a layout hash" do
      subject.should == {
        :page_size => [50.cm, 70.cm],
        :size => [50.cm, 70.cm],
        :orientation => :landscape,
        :top_margin => 10.cm,
        :bottom_margin => 5.cm
      }
    end
  end

  describe ".page_size" do
    subject { layout.page_size }

    context "predefined size" do
      before { layout.size = "A4" }

      it { should == "A4" }
    end

    context "custom size" do
      before do
        layout.width = 10.cm
        layout.height = 15.cm
      end

      it { should == [10.cm, 15.cm] }
    end
  end

  describe ".array_page_sizes" do
    subject { layout.send(:array_page_sizes) }

    context "with custom size" do
      before do
        layout.width = 10
        layout.height = 20
      end

      it "should return the sizes" do
        should == [10, 20]
      end
    end

    context "with predefined size" do
      before { layout.size = "A4" }

      it "should ask Prawn what the size is in points" do
        should == [595.28, 841.89]
      end
    end
  end

  describe ".content_width" do
    before do
      layout.margin.inner = 2
      layout.margin.outer = 3
      layout.width = 10
      layout.height = 10
    end
    subject { layout.content_width }

    it { should == 5 }
  end

  describe ".margin" do
    before { layout.margin { |m| m.top = 1 } }
    subject { layout.margin }

    it { should be_instance_of Kotoba::Layout::Margin }
    its(:top) { should == 1 }
  end

  describe ".header" do
    before { layout.header { |h| h.content = 1 } }
    subject { layout.header }

    it { should be_instance_of Kotoba::Layout::RecurringElement }
    its(:content) { should == 1 }
  end

  describe ".footer" do
    before { layout.footer { |h| h.content = 1 } }
    subject { layout.footer }

    it { should be_instance_of Kotoba::Layout::RecurringElement }
    its(:content) { should == 1 }
  end

  describe ".default" do
    before { layout.default { |d| d.color = "red" } }
    subject { layout.default }

    it { should be_instance_of Kotoba::Layout::DefaultStyling }
    it { should be_kind_of Kotoba::Layout::Styling }
    its(:color) { should == "red" }
  end

  describe ".paragraph" do
    before { layout.paragraph { |p| p.indent = false } }
    subject { layout.paragraph }

    it { should be_instance_of Kotoba::Layout::Paragraph }
    its(:indent) { should be_false }
  end

  describe ".heading" do
    before do
      layout.heading 1 do |h|
        h.color = "222222"
      end
    end
    subject { layout.heading(1) }

    it { should be_instance_of Kotoba::Layout::Styling }
    its(:color) { should == "222222" }
  end

  describe ".quote" do
    subject { layout.quote }

    it { should be_instance_of Kotoba::Layout::Styling }
  end

  describe ".code" do
    subject { layout.code }

    it { should be_instance_of Kotoba::Layout::Styling }
  end

  describe Kotoba::Layout::Margin do
    let(:margin) { Kotoba::Layout::Margin.new }
    before do
      margin.top = 1
      margin.bottom = 2
      margin.inner = 3
      margin.outer = 4
    end
    subject { margin }

    its(:top) { should == 1 }
    its(:bottom) { should == 2 }
    its(:inner) { should == 3 }
    its(:outer) { should == 4 }
  end

  describe Kotoba::Layout::Styling do
    let(:styling) { Kotoba::Layout::Styling.new }
    subject { styling }

    context "with styling" do
      before do
        styling.font = "My font"
        styling.size = 15.pt
        styling.color = "000000"
        styling.align = :right
        styling.direction = :rtl
        styling.character_spacing = 1.pt
        styling.line_height = 20.pt
        styling.style = ["bold", "italic"]
        styling.prefix = "In the beginning"
      end

      its(:font) { should == "My font" }
      its(:size) { should == 15.pt }
      its(:color) { should == "000000" }
      its(:align) { should == :right }
      its(:direction) { should == :rtl }
      its(:character_spacing) { should == 1.pt }
      its(:line_height) { should == 20.pt }
      its(:style) { should == ["bold", "italic"] }
      pending "not yet supported" do
        its(:prefix) { should == "In the beginning" }
      end
    end

    describe "without styling, should fall back on default" do
      its(:font) { should == "Times-Roman" }
      its(:size) { should == 12.pt }
      its(:color) { should == "000000" }
      its(:align) { should == :left }
      its(:direction) { should == :ltr }
      its(:character_spacing) { should == 0 }
      its(:line_height) { should == 12.pt }
      its(:style) { should be_empty }
      pending "not yet supported" do
        its(:prefix) { should be_empty }
      end
    end

    pending ".using_prawn_font?"
  end

  describe Kotoba::Layout::DefaultStyling do
    let(:default) { Kotoba::Layout::DefaultStyling.new }
    subject { default }

    it { should be_kind_of Kotoba::Layout::Styling }
    its(:font) { should == "Times-Roman" }
    its(:size) { should == 12.pt }
    its(:color) { should == "000000" }
    its(:align) { should == :left }
    its(:direction) { should == :ltr }
    its(:character_spacing) { should == 0 }
    its(:line_height) { should == 12.pt }
    its(:style) { should be_empty }
    pending "not yet supported" do
      its(:prefix) { should be_empty }
    end
  end

  describe Kotoba::Layout::Paragraph do
    let(:paragraph) { Kotoba::Layout::Paragraph.new }
    before do
      paragraph.indent = true
      paragraph.indent_with = 1
      paragraph.book_indent = false
    end
    subject { paragraph }

    its(:indent) { should be_true }
    its(:indent_with) { should == 1 }
    its(:book_indent) { should be_false }

    pending ".to_hash"
  end

  describe Kotoba::Layout::RecurringElement do
    let(:element) { Kotoba::Layout::RecurringElement.new }
    subject { element }

    it { should be_instance_of Kotoba::Layout::RecurringElement }
    it { should be_kind_of Kotoba::Layout::Styling }

    describe ".content" do
      before do
        element.content do
          "hello!"
        end
      end
      subject { element.content }

      it { should be_instance_of Proc }
    end

    describe ".page_numbering" do
      before do
        element.page_numbering do |n|
          n.active = true
        end
      end
      subject { element.page_numbering }

      it do
        should be_instance_of Kotoba::Layout::RecurringElement::PageNumbering
      end
      its(:active) { should be_true }
    end

    describe Kotoba::Layout::RecurringElement::PageNumbering do
      let(:numbering) { Kotoba::Layout::RecurringElement::PageNumbering.new }
      before do
        numbering.active = true
        numbering.string = "Page <page> of <total>"
        numbering.align = :right
        numbering.start_count_at = 1
      end
      subject { numbering }

      its(:active) { should be_true }
      its(:string) { should == "Page <page> of <total>" }
      its(:align) { should == :right }
      its(:start_count_at) { should == 1 }

      describe ".format" do
        before do
          numbering.start_count_at = 0
        end
        subject { numbering.format(1, 2) }

        it "should insert page number and total" do
          subject.should == "Page 1 of 2"
        end

        context "without page total" do
          subject { numbering.format(1) }

          it { should == "Page 1 of <total>" }
        end
      end
    end
  end
end
