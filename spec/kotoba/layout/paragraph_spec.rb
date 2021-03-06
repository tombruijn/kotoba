require "spec_helper"

describe Kotoba::Layout::Paragraph do
  before :all do
    @paragraph = Kotoba::Layout::Paragraph.new
    @paragraph.indent = true
    @paragraph.indent_with = 1
    @paragraph.book_indent = false
  end
  subject { @paragraph }

  its(:indent) { should be_true }
  its(:indent_with) { should == 1 }
  its(:book_indent) { should be_false }

  describe ".indent?" do
    context "with book indent" do
      before :all do
        @paragraph.indent = true
        @paragraph.indent_with = 1
        @paragraph.book_indent = true
      end

      it { @paragraph.indent?(1).should be_false }
      it { @paragraph.indent?(2).should be_true }
    end

    context "without book indent" do
      before :all do
        @paragraph.indent = true
        @paragraph.indent_with = 1
        @paragraph.book_indent = false
      end

      it { @paragraph.indent?(1).should be_true }
      it { @paragraph.indent?(2).should be_true }
    end

    context "without indent" do
      before(:all) { @paragraph.indent = false }

      it { @paragraph.indent?(1).should be_false }
      it { @paragraph.indent?(2).should be_false }
    end
  end

  describe ".to_h" do
    subject { @paragraph.to_h }

    context "with indent" do
      before { @paragraph.indent = true }

      it { should == { indent_paragraphs: 1 } }
    end

    context "without indent" do
      before { @paragraph.indent = false }

      it { should be_empty }
    end
  end
end
