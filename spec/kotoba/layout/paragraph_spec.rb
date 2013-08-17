require "spec_helper"

describe Kotoba::Layout::Paragraph do
  before do
    @paragraph = Kotoba::Layout::Paragraph.new
    @paragraph.indent = true
    @paragraph.indent_with = 1
    @paragraph.book_indent = false
  end
  subject { @paragraph }

  its(:indent) { should be_true }
  its(:indent_with) { should == 1 }
  its(:book_indent) { should be_false }

  pending ".to_hash"
end
