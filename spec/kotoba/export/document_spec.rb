require "spec_helper"

describe Kotoba::Export::Document do
  let(:document) { Kotoba::Export::Document.new(Kotoba.config.to_h) }
  before :all do
    Kotoba.clear_config!
    set_default_config
  end

  describe "page size" do
    before do
      Kotoba.config do |c|
        @first_layout = c.layout_for 1 do |l|
          l.width = 1000
          l.height = 1000
        end
        @second_layout = c.layout_for 2 do |l|
          l.width = 2000
          l.height = 2000
        end
        @default_layout = c.layout do |l|
          l.width = 3000
          l.height = 3000
        end
        @third_layout = c.layout_for 4..5 do |l|
          l.orientation = :landscape
          l.width = 4000
          l.height = 5000
        end
      end
    end

    describe ".layout" do
      context "with layout for specific page" do
        it "should retrieve layout for page" do
          # First specific layout
          document.page_number.should == 1
          document.layout.should == @first_layout
          document.start_new_page

          # Second specific layout
          document.page_number.should == 2
          document.layout.should == @second_layout
          document.start_new_page

          # Default layout
          document.page_number.should == 3
          document.layout.should == @default_layout
          document.start_new_page

          # Ranged layout
          document.page_number.should == 4
          document.layout.should == @third_layout
        end
      end
    end

    describe ".render" do
      before do
        document.text "first page"
        document.start_new_page
        document.text "second page"
        document.start_new_page
        document.text "third page"
        document.start_new_page
        document.text "fourth page"
        document.start_new_page
        document.text "fifth page"
      end
      subject { PDF::Inspector::Page.analyze(document.render).pages }

      it "should use the configured layout per page" do
        subject[0][:size].should == [1000, 1000]
        subject[1][:size].should == [2000, 2000]
        subject[2][:size].should == [3000, 3000]
      end

      it "should put page in correct orientation" do
        subject[3][:size].should == [4000, 5000]
        subject[4][:size].should == [4000, 5000]
      end
    end
  end

  describe "metadata" do
    before do
      Time.stub(:now => "stubbed time")
      Kotoba.config do |c|
        c.title = "Test title"
        c.subject = "Test subject"
        c.keywords = "Test keywords"
        c.creator = "The creator"
        c.authors = ["Tom de Bruijn", "John Doe"]
      end
      reader = read_document(document)
      @metadata = PDF::Reader.new(reader).info
    end
    subject { @metadata }

    it "should add standard values" do
      subject[:CreationDate].should == "stubbed time"
      subject[:Title].should == "Test title"
      subject[:Subject].should == "Test subject"
      subject[:Keywords].should == "Test keywords"
      subject[:Creator].should == "The creator"
      subject[:Author].should == "Tom de Bruijn, John Doe"
      subject[:Producer].should == "Kotoba"
    end

    context "with custom metadata" do
      before(:all) { Kotoba.config.metadata = {:Grok => "Test property"} }

      its([:Grok]) { should == "Test property" }
    end
  end

  describe "fonts" do
    before do
      Kotoba.clear_config!
      Kotoba.config do |c|
        c.add_font "Nobile", {
          normal: "Nobile-Regular.ttf",
          italic: "Nobile-Italic.ttf",
          bold: "Nobile-Bold.ttf",
          bold_italic: "Nobile-BoldItalic.ttf"
        }
        c.layout.default do |d|
          d.font = "Nobile"
        end
      end
      document.register_fonts!
    end

    it "should add text with custom font" do
      document.add_chapter double(source: [
        "This text is printed in the Nobile font. Some _italic "\
        "text_ and some __strong text__ and _**together**_."
      ])

      text = PDF::Inspector::Text.analyze(document.render)
      fonts = text.font_settings.map { |e| e[:name].to_s.gsub(/\A\w+\+/, "") }
      fonts.should include("Nobile-Regular")
      fonts.should include("Nobile-Italic")
      fonts.should include("Nobile-Bold")
      fonts.should include("Nobile-BoldItalic")
    end
  end
end
