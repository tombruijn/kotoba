require "spec_helper"

describe Kotoba do
  describe "paths" do
    it "should have LIB_DIR" do
      Kotoba::LIB_DIR.should include "kotoba"
    end

    it "should have BIN_DIR" do
      Kotoba::BIN_DIR.should include Kotoba::LIB_DIR
      Kotoba::BIN_DIR.should include "bin"
    end

    it "should detect APP_DIR" do
      Kotoba::APP_DIR.should be_instance_of(Pathname)
      Kotoba::APP_DIR.to_s.length.should > 1
    end

    it "should have BOOK_DIR" do
      Kotoba::BOOK_DIR.should include Kotoba::APP_DIR.to_s
      Kotoba::BOOK_DIR.should include "book"
    end

    it "should have ASSETS_DIR" do
      Kotoba::ASSETS_DIR.should include Kotoba::BOOK_DIR
      Kotoba::ASSETS_DIR.should include "assets"
    end

    it "should have BUILD_DIR" do
      Kotoba::BUILD_DIR.should include Kotoba::APP_DIR.to_s
      Kotoba::BUILD_DIR.should include "build"
    end
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
        config.export_to :pdf
      end
    end

    it "should call the configured exporters" do
      Kotoba::Export::Base.should_receive(:export)
    end

    after { Kotoba.export }
  end
end
