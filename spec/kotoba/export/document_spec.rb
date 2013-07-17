require "spec_helper"

describe Kotoba::Document do
  let(:document) { Kotoba::Document.new }
  before :all do
    Kotoba.config do |c|
      c.layout do |l|
        l.width = 10
        l.height = 20
        l.margin do |m|
          m.top = 1
          m.bottom = 2
          m.outer = 3
          m.inner = 4
        end
      end
    end
  end

  describe ".page_numbering!" do
    pending
  end

  describe ".page_numbering_for" do
    let(:document) { Kotoba::Document.new }
    let(:element) { Kotoba::Layout::RecurringElement.new }
    let(:numbering) { Kotoba::Layout::RecurringElement::PageNumbering.new }
    before do
      element.color = "FF0000"
      element.stub(:page_numbering => numbering)
    end

    context "with page numbering active" do
      before { numbering.active = true }

      it "should add numbering" do
        document.should_receive(:number_pages).with("<page>", {
          :at => kind_of(Proc),
          :width => 3,
          :align => :center,
          :start_count_at => 1,
          :color => "FF0000"
        })
      end
    end

    context "with page numbering not active" do
      before { numbering.active = false }

      it "should not add numbering" do
        document.should_not_receive(:number_pages)
      end
    end

    after { document.page_numbering_for(:header, element) }
  end

  pending "header!"
  pending "footer!"

  describe ".header_position" do
    subject { document.header_position }

    it { should be_kind_of(Proc) }

    context "x-axis / left position" do
      before { document.should_receive(:left_position).and_call_original }

      it { subject[0].should == 0 }
    end

    context "y-axis / top position" do
      before { document.should_receive(:header_top_position).and_call_original }

      it { subject[1].should == 18 }
    end
  end

  describe ".header_top_position" do
    subject { document.header_top_position }

    it { should == 18 }
  end

  describe ".footer_position" do
    subject { document.footer_position }

    it { should be_kind_of(Proc) }

    context "x-axis / left position" do
      before { document.should_receive(:left_position).and_call_original }

      it { subject[0].should == 0 }
    end

    context "y-axis / top position" do
      before { document.should_receive(:footer_top_position).and_call_original }

      it { subject[1].should == 0 }
    end
  end

  describe ".footer_top_position" do
    subject { document.footer_top_position }

    it { should == 0 }
  end

  describe ".left_position" do
    subject { document.left_position }

    context "on odd page number" do
      before { document.stub(:page_number => 1) }

      it "should left align based on default location of page" do
        should == 0
      end
    end

    context "on even page number" do
      before { document.stub(:page_number => 2) }

      it "should left align based on difference in inner and outer margin" do
        should == -1
      end
    end
  end
end
