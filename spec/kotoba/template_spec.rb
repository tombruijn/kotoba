require "spec_helper"

describe Kotoba::Template do
  let(:text) { "" }
  let(:template) { Kotoba::Template.new("file.md", text) }

  describe "new" do
    before :all do
      @template = Kotoba::Template.new("file.md", <<-TEXT
---
title: "Meta data"
---
First section


Second section
        TEXT
      )
    end
    subject { @template }

    its(:file) { should == "file.md" }
    its(:source) { should include "First section" }
    its(:metadata) { should_not be_empty }
  end

  describe ".extract_metadata" do
    before { template.extract_metadata }
    subject { template.metadata }

    context "file with metadata" do
      let(:text) do
        <<-TEXT
---
title: "Meta data"
author: Jane Doe
---
# Header
Actual content here
        TEXT
      end

      it "should extract metadata" do
        should == { "title" => "Meta data", "author" => "Jane Doe" }
      end

      it "should remove metadata from source" do
        template.source.should_not include "title: "
        template.source.should_not include "Jane Doe"
      end
    end

    context "a file without metadata" do
      let(:text) { "hello world" }

      it "should not find metadata" do
        should be_empty
      end
    end
  end

  describe ".source" do
    let(:text) do
      <<-TEXT
First section and paragraph

First section with second paragraph

___PAGE___

First section with third paragraph


Second section with first paragraph

Second section with second paragraph
      TEXT
    end
    subject { template.source }

    context "with sections support" do
      before { Kotoba.config.support_sections = true }

      its([0]) {
        should == "First section and paragraph\n\nFirst section with second "\
        "paragraph\n"
      }
      its([1]) { should == Kotoba::Template::PAGE_BREAK_TAG }
      its([2]) { "\nFirst section with third paragraph" }
      its([3]) {
        should == "Second section with first paragraph\n\nSecond section with "\
          "second paragraph\n"
      }

      context "with excessive line breaks" do
        let(:text) { "section 1\n\n\n\n\n\n___PAGE___\n\n\n\n\n\nsection 2" }

        its([0]) { should == "section 1" }
        its([1]) { should == Kotoba::Template::PAGE_BREAK_TAG }
        its([2]) { should == "\n\nsection 2" }
      end
    end

    context "without sections support" do
      before { Kotoba.config.support_sections = false }

      its([0]) {
        should == "First section and paragraph\n\nFirst section with second "\
        "paragraph\n"
      }
      its([1]) { should == Kotoba::Template::PAGE_BREAK_TAG }
      its([2]) {
        should == "\nFirst section with third paragraph\n\n\n"\
          "Second section with first paragraph\n\nSecond section with "\
          "second paragraph\n"
      }
    end
  end
end
