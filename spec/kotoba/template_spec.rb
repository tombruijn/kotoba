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


Second section with first pagraph

Second section with second paragraph
      TEXT
    end
    subject { template.source }

    context "with sections support" do
      before { Kotoba.config.support_sections = true }

      its([0]) {
        should == "First section and paragraph\n\nFirst section with second "\
        "paragraph"
      }
      its([1]) {
        should == "Second section with first pagraph\n\nSecond section with "\
          "second paragraph\n"
      }
      its(:length) { should == 2 }
    end

    context "without sections support" do
      before { Kotoba.config.support_sections = false }

      its([0]) {
        should == "First section and paragraph\n\nFirst section with second "\
        "paragraph\n\n\nSecond section with first pagraph\n\nSecond section "\
        "with second paragraph\n"
      }
      its(:length) { should == 1 }
    end
  end
end
