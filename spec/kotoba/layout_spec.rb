require "spec_helper"

describe Kotoba::Layout do
  let(:layout) { Kotoba::Layout.new }

  describe ".to_h" do
    before do
      layout.margin.top = 10.cm
      layout.margin.bottom = 5.cm
      layout.margin.inner = 6.cm
      layout.margin.outer = 7.cm
      layout.orientation = :landscape
      layout.width = 50.cm
      layout.height = 70.cm
    end
    subject { layout.to_h(1) }

    it "should return a layout hash" do
      subject.should include page_size: [50.cm, 70.cm],
        size: [50.cm, 70.cm],
        orientation: :landscape,
        top_margin: 10.cm,
        bottom_margin: 5.cm
    end

    context "odd pages" do
      it "should return a layout hash" do
        subject.should include left_margin: 6.cm, right_margin: 7.cm
      end
    end

    context "even pages" do
      subject { layout.to_h(2) }

      it "should change inner and outer margins" do
        subject.should include left_margin: 7.cm, right_margin: 6.cm
      end
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

  describe "page size methods" do
    context "custom size" do
      before do
        layout.width = 50.cm
        layout.height = 100.cm
      end

      it { layout.page_width.should == 50.cm }
      it { layout.page_height.should == 100.cm }
    end

    context "prawn size" do
      before { layout.size = "A5" }

      it { layout.page_width.should == 419.53 }
      it { layout.page_height.should == 595.28 }
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
end
