require "spec_helper"

describe Kotoba::Export::Pdf do
  before :all do
    @exporter = Kotoba::Export::Pdf.new
    Kotoba.config do |config|
      config.filename = "pdf-test"
      config.export_to :pdf
    end
  end

  describe "chapter_on_new_page configuration" do
    let(:template_1) { Kotoba::Template.new("/dir_1/file_1.md", "page 1") }
    let(:template_2) { Kotoba::Template.new("/dir_2/file_2.md", "page 2") }
    let(:template_3) { Kotoba::Template.new("/dir_3/file_3.md", "page 3") }
    before do
      Kotoba.config.chapter_on_new_page = true
      Kotoba.book.stub(:templates => [template_1, template_2, template_3])
      @exporter.export
    end

    it "should start a new page after template dir change" do
      pages = PDF::Inspector::Page.analyze(File.new(@exporter.file, "r+")).pages
      pages.size.should == 3
      pages[0][:strings].should include "page 1"
      pages[1][:strings].should include "page 2"
      pages[2][:strings].should include "page 3"
    end
  end

  describe "sections support" do
    let(:exporter) { Kotoba::Export::Pdf.new }
    let(:template) { Kotoba::Template.new("a file", "source of a file") }
    before do
      exporter.should_receive(:prawn_options).and_return({})
      book = Kotoba::Book.new
      book.instance_variable_set("@templates", [template])
      Kotoba.should_receive(:book).and_return(book)
    end

    context "on" do
      let(:section) { "I'm a section!" }
      let!(:maruku) { Maruku.new(section) }

      it "should call templates for sections" do
        template.should_receive(:sections).and_return([section])
        Maruku.should_receive(:new).with(section).and_return(maruku)
        maruku.should_receive(:to_prawn).with(kind_of(Prawn::Document))
      end

      pending "should insert section spacing"
    end

    context "off" do
      let(:source) { "I'm a source!" }
      let!(:maruku) { Maruku.new(source) }
      before { Kotoba.config.support_sections = false }

      it "should call for template source" do
        template.should_receive(:source).and_return(source)
        Maruku.should_receive(:new).with(source).and_return(maruku)
        maruku.should_receive(:to_prawn).with(kind_of(Prawn::Document))
      end
    end

    after { exporter.export }
  end

  describe ".export" do
    pending "book data" do
      before do
        parser = Kotoba::Parser.new
        Kotoba::Parser.should_receive(:new).and_return(parser)
        parser.should_receive(:files).
          and_return(
            [File.join(Kotoba::BOOK_DIR, "chapters", "chapter_1", "markdown.md")
          ])
      end

      it "should move cursor between chapters sections" do
        pending
      end

      after { @exporter.export }
    end

    context "build" do
      before :all do
        clear_tmp_directory
        Kotoba::Export::Base.prepare_build_directory
        @exporter.export
      end

      it "should write the file" do
        File.exists?(File.join(Kotoba::BUILD_DIR, "pdf-test.pdf"))
          .should be_true
      end
    end
  end
end
