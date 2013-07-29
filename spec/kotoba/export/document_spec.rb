require "spec_helper"

describe Kotoba::Document do
  let(:document) { Kotoba::Document.new(Kotoba.config.to_h) }
  before do
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

  describe "layout" do
    before do
      Kotoba.clear_config!
      Kotoba.config do |c|
        @first_layout = c.layout_for 1 do |l|
          l.width = 10.cm
          l.height = 10.cm
        end
        @second_layout = c.layout_for 2 do |l|
          l.width = 20.cm
          l.height = 20.cm
        end
        @default_layout = c.layout do |l|
          l.width = 30.cm
          l.height = 30.cm
        end
        @third_layout = c.layout_for 4..5 do |l|
          l.orientation = :landscape
          l.width = 40.cm
          l.height = 50.cm
        end
      end
    end

    describe ".layout" do
      context "with layout for specific page" do
        it "should retrieve layout for page" do
          # First specific layout
          document.page_number.should == 1
          document.layout.should == @first_layout
          document.start_new_page

          # Second specific layout
          document.page_number.should == 2
          document.layout.should == @second_layout
          document.start_new_page

          # Default layout
          document.page_number.should == 3
          document.layout.should == @default_layout
          document.start_new_page

          # Ranged layout
          document.page_number.should == 4
          document.layout.should == @third_layout
        end
      end
    end

    describe ".render" do
      before do
        document.text "first page"
        document.start_new_page
        document.text "second page"
        document.start_new_page
        document.text "third page"
        document.start_new_page
        document.text "fourth page"
        document.start_new_page
        document.text "fifth page"
      end
      subject { PDF::Inspector::Page.analyze(document.render).pages }

      it "should use the configured layout per page" do
        subject[0][:size].should == [10.cm, 10.cm]
        subject[1][:size].should == [20.cm, 20.cm]
        subject[2][:size].should == [30.cm, 30.cm]
      end

      it "should put page in correct orientation" do
        subject[3][:size].should == [40.cm, 50.cm]
        subject[4][:size].should == [40.cm, 50.cm]
      end
    end
  end

  describe "document outline" do
    let(:headings) do
      [
        { name: "Chapter 1", page: 1, level: 1, children: [] },
        { name: "Chapter 2", page: 2, level: 1, children: [
            { name: "Chapter 3", page: 3, level: 2, children: [] }
          ]
        }
      ]
    end
    before do
      document.headings = headings
      3.times { document.start_new_page }
    end

    describe ".outline!" do
      it "should call outline generation method" do
        document.should_receive(:outline_chapter_headings).with(kind_of(Array))
        document.outline!
      end
    end

    describe ".outline_chapter_headings" do
      before { document.send(:outline_chapter_headings, headings) }

      it "should add a chapter to the outline" do
        find_chapter_by_title(document, "Chapter 1").should_not be_nil
      end

      it "should add a parent chapter to the outline" do
        find_chapter_by_title(document, "Chapter 2").should_not be_nil
      end

      it "should add nested chapters to the outline" do
        find_chapter_by_title(document, "Chapter 3").should_not be_nil
      end
    end
  end
end

# Renders and reads the document
#
# @param [Prawn::Document]
#
def read_document(document)
  StringIO.new(document.render, "r+")
end

# Renders the Prawn document to a PDF which is then read to extract
# details about the end result
#
# @param document [Prawn::Document]
# @return [PDF::Reader::ObjectHash] PDF as an object
#
def find_objects(document)
  string = read_document(document)
  PDF::Reader::ObjectHash.new(string)
end

# Outline titles are stored as UTF-16. This method accepts a UTF-8 outline title
# and returns the PDF Object that contains an outline with that name
# https://github.com/prawnpdf/prawn/blob/master/spec/outline_spec.rb#L410
#
def find_chapter_by_title(document, title)
  hash = find_objects(document)
  hash.values.select do |o|
    if o.is_a?(Hash) && o[:Title]
      title_codepoints = o[:Title].unpack("n*")
      title_codepoints.shift
      utf8_title = title_codepoints.pack("U*")
      utf8_title == title ? o : nil
    end
  end
end
