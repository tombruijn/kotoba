require "spec_helper"

describe Kotoba::Export::Document do
  let(:document) { Kotoba::Export::Document.new(Kotoba.config.to_h) }
  before { set_default_config }

  describe "page size" do
    before do
      Kotoba.clear_config!
      Kotoba.config do |c|
        @first_layout = c.layout_for 1 do |l|
          l.width = 10.cm
          l.height = 10.cm
        end
        @second_layout = c.layout_for 2 do |l|
          l.width = 20.cm
          l.height = 20.cm
        end
        @default_layout = c.layout do |l|
          l.width = 30.cm
          l.height = 30.cm
        end
        @third_layout = c.layout_for 4..5 do |l|
          l.orientation = :landscape
          l.width = 40.cm
          l.height = 50.cm
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
        subject[0][:size].should == [10.cm, 10.cm]
        subject[1][:size].should == [20.cm, 20.cm]
        subject[2][:size].should == [30.cm, 30.cm]
      end

      it "should put page in correct orientation" do
        subject[3][:size].should == [40.cm, 50.cm]
        subject[4][:size].should == [40.cm, 50.cm]
      end
    end
  end

  describe "metadata" do
    let(:document) { Kotoba::Export::Document.new(Kotoba.config.to_h) }
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
end
