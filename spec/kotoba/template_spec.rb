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
    its(:metadata) { should_not == {} }
    its(:"sections.length") { should == 2 }
  end

  describe ".extract_metadata" do
    before do
      template.extract_metadata
    end
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

      it "should find metadata" do
        should == { "title" => "Meta data", "author" => "Jane Doe" }
      end

      it "should remove metadata from source" do
        template.source.should_not include "title: "
        template.source.should_not include "Jane Doe"
      end
    end

    context "file without metadata" do
      let(:text) { "hello world" }

      it "should not find metadata" do
        should == {}
      end
    end
  end

  describe ".find_sections" do
    let(:text) do
        <<-TEXT
# Header

First section and paragraph here

Second paragraph here


Second section and first paragraph here

Second paragraph here
        TEXT
    end
    before do
      template.find_sections
    end
    subject { template.sections }

    its(:first) { should =~ /^# Header\n\nFirst section and paragraph/ }
    its(:last) { should =~ /^Second section and first paragraph here/ }
    its(:length) { should == 2 }
  end
end
