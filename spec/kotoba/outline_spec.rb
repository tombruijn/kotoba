require "spec_helper"

class OutlineTestClass
  include Kotoba::Outline
end

describe Kotoba::Outline do
  describe ".register_heading" do
    let(:outline) { OutlineTestClass.new }

    it "should register a heading" do
      outline.register_heading(name: "Chapter 1", page: 1, level: 1)
      heading = outline.headings.first
      heading.should include name: "Chapter 1", level: 1, page: 1, children: []
      heading.should_not include :parent
    end

    describe "nesting" do
      before do
        outline.register_heading(name: "heading 1.1", level: 1)
        outline.register_heading(name: "heading 2.1", level: 2)
        outline.register_heading(name: "heading 2.2", level: 2)
        outline.register_heading(name: "heading 3.1", level: 3)
        outline.register_heading(name: "heading 1.2", level: 1)
      end

      it "should find nest headings" do
        headings = outline.headings
        headings[0].should include name: "heading 1.1", level: 1
        headings[0].should_not include :parent
        headings[1].should include name: "heading 1.2", level: 1
        headings[0].should_not include :parent

        first_level_children = headings[0][:children]
        first_level_children[0].should include name: "heading 2.1", level: 2,
          parent: headings[0]
        first_level_children[1].should include name: "heading 2.2", level: 2,
          parent: headings[0]

        second_level_children = first_level_children[1][:children]
        second_level_children[0].should include name: "heading 3.1", level: 3,
          parent: first_level_children[1]
      end
    end
  end
end
