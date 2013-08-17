require "spec_helper"

describe Kotoba::Layout::RecurringElement do
  it { should be_instance_of Kotoba::Layout::RecurringElement }
  it { should be_kind_of Kotoba::Layout::Styling }

  describe ".content" do
    before :all do
      @element = Kotoba::Layout::RecurringElement.new
      @element.content do
        "hello!"
      end
    end
    subject { @element.content }

    it { should be_instance_of Proc }
  end

  describe ".page_numbering" do
    before :all do
      @element = Kotoba::Layout::RecurringElement.new
      @element.page_numbering do |n|
        n.active = true
      end
    end
    subject { @element.page_numbering }

    it {
      should be_instance_of Kotoba::Layout::RecurringElement::PageNumbering
    }
    its(:active) { should be_true }
  end

  describe Kotoba::Layout::RecurringElement::PageNumbering do
    before :all do
      @numbering = Kotoba::Layout::RecurringElement::PageNumbering.new
      @numbering.active = true
      @numbering.string = "Page <page> of <total>"
      @numbering.align = :right
      @numbering.start_count_at = 1
    end
    subject { @numbering }

    its(:active) { should be_true }
    its(:string) { should == "Page <page> of <total>" }
    its(:align) { should == :right }
    its(:start_count_at) { should == 1 }

    describe ".format" do
      before :all do
        @numbering = Kotoba::Layout::RecurringElement::PageNumbering.new
        @numbering.string = "Format <page> of <total>"
        @numbering.start_count_at = 0
      end
      subject { @numbering.format(1, 2) }

      it "should insert page number and total" do
        subject.should == "Format 1 of 2"
      end

      context "without page total" do
        subject { @numbering.format(1) }

        it { should == "Format 1 of <total>" }
      end
    end
  end
end
