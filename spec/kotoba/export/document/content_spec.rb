require "spec_helper"

describe Kotoba::Export::Document do
  let(:document) { Kotoba::Export::Document.new }

  describe "#generate" do
    let(:filename) { File.join(Kotoba::BUILD_DIR, "file.pdf") }
    before { set_default_config }

    it "should call content methods" do
      Kotoba::Export::Document.any_instance.should_receive(:add_book!)
      Kotoba::Export::Document.any_instance
        .should_receive(:add_recurring_elements!)
      Kotoba::Export::Document.any_instance.should_receive(:outline!)
      Kotoba::Export::Document.generate(filename)
    end

    it "should generate the file" do
      Kotoba::Export::Document.generate(filename)
      File.exists?(filename).should be_true
    end

    after { Kotoba.clear_config! }
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
    let(:source) { "section 1\n\n\nsection 2" }
    let(:template) { Kotoba::Template.new("a file", source) }
    before { Kotoba.book.stub(:templates => [template]) }

    describe "adding content" do
      context "with section support" do
        before :all do
          @kram_one = Kramdown::Document.new("section 1")
          @kram_two = Kramdown::Document.new("section 2")
          Kotoba.config.support_sections = true
        end

        it "should call for template source and return sections" do
          template.should_receive(:source).and_call_original
          Kramdown::Document.should_receive(:new).with("section 1").
            and_return(@kram_one)
          Kramdown::Document.should_receive(:new).with("section 2").
            and_return(@kram_two)
          @kram_one.should_receive(:to_prawn).with(kind_of(Prawn::Document))
          @kram_two.should_receive(:to_prawn).with(kind_of(Prawn::Document))
        end

        describe "section spacing" do
          let(:template) do
            Kotoba::Template.new("a file",
              "section 1\n\n\nsection 2")
          end
          before(:all) { Kotoba.config.section_spacing = 10.mm }

          it "should add spacing between sections but not after last section" do
            document.should_receive(:move_down).once.with(10.mm)
          end

          context "with page breaks" do
            let(:template) {
              Kotoba::Template.new("a file", "s1\n\n\n___PAGE___\n\n\ns2")
            }

            it "should not add spacing between sections and page breaks" do
              document.should_not_receive(:move_down)
            end
          end
        end
      end

      context "without section support" do
        before do
          Kotoba.config.support_sections = false
          @kram = Kramdown::Document.new(source)
        end

        it "should call for template source" do
          template.should_receive(:source).and_call_original
          Kramdown::Document.should_receive(:new).with(source).and_return(@kram)
          @kram.should_receive(:to_prawn).with(kind_of(Prawn::Document))
        end
      end

      after { document.add_chapter(template) }
    end

    describe "page breaks" do
      let(:template) {
        Kotoba::Template.new("a file", "page 1\n___PAGE___\npage 2")
      }

      it "should start a new page on page separator" do
        document.add_chapter(template)
        pages = PDF::Inspector::Page.analyze(document.render).pages
        pages.size.should == 2
        pages[0][:strings].should include "page 1"
        pages[1][:strings].should include "page 2"
      end
    end
  end
end
