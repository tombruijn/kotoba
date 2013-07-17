require "spec_helper"

describe Kotoba::Export::Pdf do
  before :all do
    @exporter = Kotoba::Export::Pdf.new
    Kotoba.config do |config|
      config.filename = "pdf-test"
      config.export_to :pdf
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
      before { Kotoba.config.stub(:support_sections => false) }

      it "should call for template source" do
        template.should_receive(:source).and_return(source)
        Maruku.should_receive(:new).with(source).and_return(maruku)
        maruku.should_receive(:to_prawn).with(kind_of(Prawn::Document))
      end
    end

    after { exporter.export }
  end

  describe ".export" do
    context "book data" do
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
