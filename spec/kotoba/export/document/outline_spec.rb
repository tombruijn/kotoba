require "spec_helper"

describe Kotoba::Export::Document do
  describe "document outline" do
    before :all do
      document = Kotoba::Export::Document.new
      document.register_heading(name: "Chapter 1", page: 1, level: 1)
      document.register_heading(name: "Chapter 2", page: 2, level: 1)
      document.register_heading(name: "Chapter 3", page: 3, level: 2)
      3.times { document.start_new_page }
      document.outline!
      @objects = find_objects(document)
    end

    it "should add a chapter to the outline root" do
      chapter_1 = find_chapter_by_title(@objects, "Chapter 1")
      chapter_1.should_not be_nil
      outline = find_outline_root(@objects)
      @objects[chapter_1[:Parent]].should == outline
    end

    it "should add a parent chapter to the outline root" do
      chapter_2 = find_chapter_by_title(@objects, "Chapter 2")
      chapter_2.should_not be_nil
      outline = find_outline_root(@objects)
      @objects[chapter_2[:Parent]].should == outline
    end

    it "should add nested chapters to the outline under their parent" do
      chapter_3 = find_chapter_by_title(@objects, "Chapter 3")
      chapter_3.should_not be_nil
      parent = @objects[chapter_3[:Parent]]
      parent.should == find_chapter_by_title(@objects, "Chapter 2")
    end
  end
end

# Outline titles are stored as UTF-16. This method accepts a UTF-8 outline title
# and returns the PDF Object that contains an outline with that name
# https://github.com/prawnpdf/prawn/blob/master/spec/outline_spec.rb#L410
#
def find_chapter_by_title(objects, title)
  objects.values.select do |o|
    if o.is_a?(Hash) && o[:Title]
      title_codepoints = o[:Title].unpack("n*")
      title_codepoints.shift
      utf8_title = title_codepoints.pack("U*")
      utf8_title == title
    end
  end.first
end

# Finds the outline root from the document
#
# @param objects [PDF::Reader::ObjectHash] PDF as an object
#
def find_outline_root(objects)
  objects.values.select do |o|
    o.is_a?(Hash) && o[:Type] == :Outlines
  end.first
end
