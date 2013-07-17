require "spec_helper"

describe Kotoba::Export::Base do
  describe ".get" do
    context "existing exporter" do
      subject { Kotoba::Export::Base.get(:text) }

      it { should == Kotoba::Export::Text }
    end

    context "not existing exporter" do
      it "should raise error" do
        expect {
          Kotoba::Export::Base.get(:none)
        }.to raise_error
      end
    end
  end

  describe "#export" do
    before do
      @exporter = mock
      Kotoba.config.should_receive(:check_requirements)
      Kotoba.config.should_receive(:exporters).and_return([@exporter])
    end

    it "should call the configured exporters and prepare for export" do
      @exporter.should_receive(:export)
      Kotoba::Export::Base.should_receive(:prepare_build_directory)
    end

    after { Kotoba::Export::Base.export }
  end

  describe "#prepare_build_directory" do
    before { clear_tmp_directory }

    it "should create a directory" do
      Dir.exists?(Kotoba::BUILD_DIR).should be_false
      Kotoba::Export::Base.prepare_build_directory
      Dir.exists?(Kotoba::BUILD_DIR).should be_true
    end
  end

  describe ".filename_with_extension" do
    let(:export) { Kotoba::Export::Base.new }
    context "with extension" do
      before do
        Kotoba.config.should_receive(:filename).and_return("file")
        export.should_receive(:extension).twice.and_return("ext")
      end
      subject { export.filename_with_extension }

      it { should == "file.ext" }
    end

    context "without extension" do
      before do
        Kotoba.config.should_receive(:filename).and_return("just_a_file")
        export.should_receive(:extension).and_return(nil)
      end
      subject { export.filename_with_extension }

      it { should == "just_a_file" }
    end
  end

  describe ".delete" do
    let(:exporter) { Kotoba::Export::Base.new }
    before do
      exporter.filename = "remove_me_please"
      # raise exporter.file
      File.open(exporter.file, "w") do |file|
        file << "hello!"
      end
      File.exists?(exporter.file).should be_true
    end

    it "should delete file if it exists" do
      exporter.delete
      File.exists?(exporter.file).should be_false
    end
  end
end
