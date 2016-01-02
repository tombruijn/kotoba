require "spec_helper"

describe Kotoba::Export::Pdf do
  let(:exporter) { Kotoba::Export::Pdf.new }
  before do
    set_default_config
    Kotoba.config do |config|
      config.filename = "pdf-test"
      config.export_to :pdf
    end
  end

  describe ".export" do
    describe "build" do
      before do
        clear_tmp_directory
        Kotoba::Export::Base.prepare_build_directory
        exporter.export
      end

      it "should write the file" do
        File.exists?(File.join(Kotoba::BUILD_DIR, "pdf-test.pdf"))
          .should be_true
      end
    end
  end

  after { Kotoba.clear_config! }
end
