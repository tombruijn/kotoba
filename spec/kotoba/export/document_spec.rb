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
    subject { document.send(:header_position) }

    it { should be_kind_of(Array) }

    context "x-axis / left position" do
      it { subject[0].should == 0 }
    end

    context "y-axis / top position" do
      it { subject[1].should == 18 }
    end
  end

  describe ".header_top_position" do
    subject { document.send(:header_top_position) }

    it { should == 18 }
  end

  describe ".footer_position" do
    subject { document.send(:footer_position) }

    it { should be_kind_of(Array) }

    context "x-axis / left position" do
      it { subject[0].should == 0 }
    end

    context "y-axis / top position" do
      it { subject[1].should == 0 }
    end
  end

  describe ".footer_top_position" do
    subject { document.send(:footer_top_position) }

    it { should == 0 }
  end

  describe ".left_position" do
    subject { document.send(:left_position) }

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

# Renders the Prawn document to a PDF which is then read to extract
# details about the end result
#
def render_and_find_objects(document)
  output = StringIO.new(document.render, "r+")
  hash = PDF::Reader::ObjectHash.new(output)
end

# Outline titles are stored as UTF-16. This method accepts a UTF-8 outline title
# and returns the PDF Object that contains an outline with that name
# https://github.com/prawnpdf/prawn/blob/master/spec/outline_spec.rb#L410
#
def find_chapter_by_title(document, title)
  hash = render_and_find_objects(document)
  hash.values.select do |o|
    if o.is_a?(Hash) && o[:Title]
      title_codepoints = o[:Title].unpack("n*")
      title_codepoints.shift
      utf8_title = title_codepoints.pack("U*")
      utf8_title == title ? o : nil
    end
  end
end
