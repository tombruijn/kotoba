require "spec_helper"

describe Kotoba::Export::Document do
  let(:document) { Kotoba::Export::Document.new(Kotoba.config.to_h) }
  let(:document) { Kotoba::Export::Document.new(Kotoba.config.to_h) }
  before { set_default_config }
  after { Kotoba.clear_config! }

  describe ".add_recurring_elements!" do
    before do
      2.times { document.start_new_page }
    end

    it "should open all pages" do
      [1, 2, 3].each do |i|
        document.should_receive(:go_to_page).with(i).and_call_original
      end
      document.add_recurring_elements!
    end

    it "should add recurring elements to the open page" do
      [:header, :footer].each do |v|
        document.should_receive(:add_recurring_element).with(v).
          exactly(3).times.and_call_original
      end
      document.add_recurring_elements!
    end

    describe "page numbering" do
      before do
        Kotoba.config.layout.header.page_numbering do |n|
          n.active = true
        end
      end

      it "should increment page numbers" do
        counters = document.instance_variable_get("@page_counters")
        counters.should be_nil
        document.add_recurring_elements!
        counters = document.instance_variable_get("@page_counters")
        counters[counters.keys.first].should == { number: 4, total: 3 }
      end

      it "should add page numbering" do
        [1, 2, 3].each do |i|
          document.should_receive(:text).with(i.to_s, kind_of(Hash))
        end
        document.add_recurring_elements!
      end

      context "with start_count_at set" do
        before do
          Kotoba.config.layout.header.page_numbering do |n|
            n.active = true
            n.start_count_at = 10
          end
        end

        it "should start counting at start_count_at value" do
          [10, 11, 12].each do |i|
            document.should_receive(:text).with(i.to_s, kind_of(Hash))
          end
          document.add_recurring_elements!
        end
      end
    end
  end

  describe ".add_recurring_element" do
    describe "custom content" do
      context "header" do
        before do
          Kotoba.config.layout.header.content do |p|
            p.text "Test header"
          end
        end

        it "should position the header" do
          document.should_receive(:canvas).and_call_original
          document.should_receive(:bounding_box).with(
            [be_within(0.001).of(4.cm), be_within(0.001).of(20.cm)],
            {
              top: be_instance_of(Proc),
              height: be_within(0.001).of(1.cm),
              width: be_within(0.001).of(3.cm)
            }
          ).and_call_original
        end

        it "should call the custom content block" do
          document.should_receive(:text).with("Test header")
        end

        after { document.add_recurring_element(:header) }
      end

      context "footer" do
        before do
          Kotoba.config.layout.footer.content do |p|
            p.text "Test footer"
          end
        end

        it "should position the footer" do
          document.should_receive(:canvas).and_call_original
          document.should_receive(:bounding_box).with(
            [be_within(0.001).of(4.cm), be_within(0.001).of(2.cm)],
            {
              top: kind_of(Proc),
              height: be_within(0.001).of(2.cm),
              width: be_within(0.001).of(3.cm)
            }
          ).and_call_original
        end

        it "should call the custom content block" do
          document.should_receive(:text).with("Test footer")
        end

        after { document.add_recurring_element(:footer) }
      end
    end

    describe "page numbering" do
      before do
        Kotoba.config.layout.footer.page_numbering do |n|
          n.active = true
        end
      end

      it "should position the page numbering" do
        document.should_receive(:canvas).and_call_original
        document.should_receive(:bounding_box).with(
          [be_within(0.001).of(4.cm), be_within(0.001).of(2.cm)],
          {
            top: kind_of(Proc),
            height: be_within(0.001).of(2.cm),
            width: be_within(0.001).of(3.cm)
          }
        ).and_call_original
        document.add_recurring_element(:footer)
      end
    end
  end

  describe ".set_page_counter" do
    let(:numbering) { Kotoba::Layout::RecurringElement::PageNumbering.new }
    subject { document.send(:set_page_counter, numbering) }

    context "with page numbers based on start_count_at" do
      before do
        document.stub(page_count: 3).stub(page_number: 1)
        numbering.start_count_at = 5
      end

      its([:number]) { should == 5 }
      its([:total]) { should == 7 }
    end

    context "with prawn page numbers" do
      before do
        document.stub(page_count: 2).stub(page_number: 1)
        numbering.start_count_at = 0
      end

      its([:number]) { should == 1 }
      its([:total]) { should == 2 }
    end
  end
end
