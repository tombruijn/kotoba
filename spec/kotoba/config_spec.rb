require "spec_helper"

describe Kotoba::Config do
  describe "block setup" do
    before :all do
      Kotoba.clear_config!
      Kotoba.config do |c|
        c.title = "My test book"
        c.authors = ["Tom de Bruijn"]
        c.filename = "my-test-book"
        c.export_to :pdf
      end
    end
    subject { Kotoba.config }

    its(:title) { should == "My test book" }
    its(:authors) { should include "Tom de Bruijn" }
    its(:filename) { should == "my-test-book" }
    its(:"exporters.first") { should be_instance_of Kotoba::Export::Pdf }
  end

  describe ".layout" do
    let(:config) { Kotoba::Config.new }

    it "should set the default layout" do
      config.layout do |l|
        l.margin.top = 1
      end

      config.layout.margin.top.should == 1
    end
  end

  describe ".layout_for" do
    let(:config) { Kotoba::Config.new }

    context "with range" do
      it "should set a layout for a page range" do
        config.layout_for 1..2 do |l|
          l.margin.top = 1
        end

        config.layout_for_page(1).margin.top.should == 1
        config.layout_for_page(2).margin.top.should == 1
      end
    end

    context "with array of pages" do
      it "should set a layout for a selected pages" do
        config.layout_for [1, 3] do |l|
          l.margin.top = 1
        end

        config.layout_for_page(1).margin.top.should == 1
        config.layout_for_page(3).margin.top.should == 1
      end
    end

    context "with integer" do
      it "should set a layout for a single page" do
        config.layout_for 1 do |l|
          l.margin.top = 1
          l.margin.bottom = 1
        end
        config.layout_for 2 do |l|
          l.margin.top = 2
          l.margin.bottom = 2
        end
        config.layout do |l|
          l.margin.top = 3
          l.margin.bottom = 3
        end

        config.layout_for_page(1).margin.top.should == 1
        config.layout_for_page(2).margin.bottom.should == 2
        config.layout_for_page(3).margin.top.should == 3
      end
    end
  end

  describe ".layout_for_page" do
    let(:config) { Kotoba::Config.new }
    let!(:first_layout) { config.layout_for(1) { |l| l.size = "A3" } }
    let!(:default_layout) { config.layout { |l| l.size = "A4" } }

    context "without specific layout specified for page" do
      it "should return the default layout" do
        config.layout_for_page(2).should == default_layout
      end
    end

    context "with specific layout specified for page" do
      it "should return the specific layout" do
        config.layout_for_page(1).should == first_layout
      end
    end
  end

  describe ".load" do
    context "with properly setup structure" do
      before :all do
        Kotoba.clear_config!
        Kotoba.config.load
      end
      subject { Kotoba.config }

      its(:title) { "My loaded book" }
      its(:filename) { "my-loaded-book" }
    end

    context "with missing config file" do
      let(:config) { Kotoba::Config.new }

      it "should raise error" do
        expect {
          capture(:stdout) { config.load("wrong-config-file.rb") }
        }.to raise_error
      end
    end
  end

  describe ".check_requirements" do
    let(:config) { Kotoba::Config.new }

    it "should check required configuration keys" do
      expect {
        config.filename = nil
        config.check_requirements
      }.to raise_error(Exception, "Configuration keys "\
        "\"filename\" are not set.")
    end
  end

  describe ".export_to" do
    before :all do
      Kotoba.clear_config!
      Kotoba.config do |config|
        config.filename = "my-test-book"
        config.export_to :pdf
      end
    end
    subject { Kotoba.config.exporters.first }

    it "should return an exporter" do
      should be_kind_of Kotoba::Export::Base
      should be_instance_of Kotoba::Export::Pdf
    end

    it "should take defaults for exporters" do
      subject.filename.should == "my-test-book"
      subject.extension.should == :pdf
    end

    context "override settings" do
      before :all do
        Kotoba.clear_config!
        Kotoba.config do |config|
          config.filename = "my-test-book"
          config.export_to :pdf do |exporter|
            exporter.filename = "hello"
            exporter.extension = "world"
          end
        end
      end

      it "should override settings for exporters" do
        subject.filename.should == "hello"
        subject.extension.should == "world"
      end
    end
  end
end
