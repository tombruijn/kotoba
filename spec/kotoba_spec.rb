require "spec_helper"

describe Kotoba do
  describe "paths" do
    it "should have LIB_DIR" do
      Kotoba::LIB_DIR.should include "kotoba"
    end

    it "should detect APP_DIR" do
      Kotoba::APP_DIR.should be_instance_of(Pathname)
      Kotoba::APP_DIR.to_s.length.should > 1
    end

    it "should have library dirs" do
      Kotoba::BIN_DIR.should include Kotoba::LIB_DIR
      Kotoba::BIN_DIR.should include "bin"
    end

    it "should have app dirs" do
      [Kotoba::BOOK_DIR, Kotoba::ASSETS_DIR].each do |path|
        path.should include Kotoba::APP_DIR.to_s
      end
    end

    pending "other dirs"
  end

  describe "initialize" do
    it "should setup book" do
      Kotoba.book.should be_instance_of(Kotoba::Book)
    end

    it "should setup config" do
      Kotoba.config.should be_instance_of(Kotoba::Config)
    end
  end

  describe ".config" do
    it "should allow block configuration" do
      expect {
        Kotoba.config {|c| c.filename = "my-test-book"}
      }.to_not raise_error
    end
  end

  describe ".export" do
    before :all do
      Kotoba.config do |config|
        config.export_to :text
      end
    end

    it "should call the configured exporters" do
      Kotoba::Export::Base.should_receive(:export)
    end

    after { Kotoba.export }
  end
end
