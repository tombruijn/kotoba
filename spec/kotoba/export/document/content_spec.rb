require "spec_helper"

describe Kotoba::Export::Document do
  let(:document) { Kotoba::Export::Document.new }

  describe "#generate" do
    let(:filename) { File.join(Kotoba::BUILD_DIR, "file.pdf") }

    it "should call content methods" do
      Kotoba::Export::Document.any_instance.should_receive(:add_book!)
      Kotoba::Export::Document.any_instance.should_receive(:add_recurring_elements!)
      Kotoba::Export::Document.any_instance.should_receive(:outline!)
      Kotoba::Export::Document.generate(filename)
    end

    it "should generate the file" do
      Kotoba::Export::Document.generate(filename)
      File.exists?(filename).should be_true
    end
  end

  describe ".add_book!" do
    before do
      Kotoba.book.stub(:templates => [
        Kotoba::Template.new("/dir_1/file_1.md", "page 1"),
        Kotoba::Template.new("/dir_2/file_2.md", "page 2"),
        Kotoba::Template.new("/dir_3/file_3.md", "page 3")
      ])
    end

    it "should add templates to document" do
      document.should_receive(:text).with("page 1", kind_of(Hash))
      document.should_receive(:text).with("page 2", kind_of(Hash))
      document.should_receive(:text).with("page 3", kind_of(Hash))
      document.add_book!
    end

    describe "chapter_on_new_page configuration" do
      before do
        Kotoba.config.chapter_on_new_page = true
        document.add_book!
      end

      it "should start a new page after template dir change" do
        pages = PDF::Inspector::Page.analyze(document.render).pages
        pages.size.should == 3
        pages[0][:strings].should include "page 1"
        pages[1][:strings].should include "page 2"
        pages[2][:strings].should include "page 3"
      end
    end
  end

  describe ".add_chapter" do
    let(:template) { Kotoba::Template.new("a file", "source of a file") }
    before { Kotoba.book.stub(:templates => [template]) }

    context "with section support" do
      let(:section) { "I'm a section!" }
      let!(:maruku) { Maruku.new(section) }
      before { Kotoba.config.support_sections = true }

      it "should call templates for sections" do
        template.should_receive(:sections).and_return([section])
        Maruku.should_receive(:new).with(section).and_return(maruku)
        maruku.should_receive(:to_prawn).with(kind_of(Prawn::Document))
      end

      pending "should insert section spacing"
    end

    context "without section support" do
      let(:source) { "I'm a source!" }
      let!(:maruku) { Maruku.new(source) }
      before { Kotoba.config.support_sections = false }

      it "should call for template source" do
        template.should_receive(:source).and_return(source)
        Maruku.should_receive(:new).with(source).and_return(maruku)
        maruku.should_receive(:to_prawn).with(kind_of(Prawn::Document))
      end
    end

    after { document.add_chapter(template) }
  end
end
