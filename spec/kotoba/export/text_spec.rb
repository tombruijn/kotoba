require "spec_helper"

describe Kotoba::Export::Text do
  before :all do
    Kotoba.config do |config|
      config.filename = "text-test"
      config.export_to :text
    end
    @exporter = Kotoba::Export::Text.new
  end

  pending ".export" do
    context "book data" do
      let(:book) { mock }
      before { @exporter.stub(:book => book) }

      it "should collect and format chapters" do
        book.should_receive(:to_html).and_return("text")
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
        File.exists?(File.join(Kotoba::BUILD_DIR, "text-test.txt"))
          .should be_true
      end
    end
  end
end
