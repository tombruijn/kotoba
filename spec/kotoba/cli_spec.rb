require "spec_helper"

describe Kotoba::Cli do
  def inside_tmp
    Dir.chdir(TMP_DIR) do
      yield
    end
  end

  describe "new" do
    before :all do
      clear_tmp_directory
      @result = inside_tmp do
        capture(:stdout) { Kotoba::Cli.start(["new", "test_project"]) }
      end
    end

    it "should create a project directory" do
      test_project = File.join(TMP_DIR, "test_project", "book")
      Dir.should exist(test_project)
      Dir.should exist(File.join(test_project, "chapters"))
    end

    context "gems" do
      it "should copy the Gemfile" do
        File.should exist(File.join(TMP_DIR, "test_project", "Gemfile"))
      end

      it "should call Bundler" do
        @result.should include "Installing gems"
      end
    end

    context "config file" do
      before :all do
        file = File.join(TMP_DIR, "test_project", "config.rb")
        @config_content = File.read(file)
      end
      subject { @config_content }

      it "should fill in config details" do
        should include "title = \"test_project\""
        should include "filename = \"test_project\""
      end
    end
  end

  describe "export" do
    before do
      Kotoba.config.should_receive(:load)
      Kotoba.should_receive(:export)
      @result = capture(:stdout) { Kotoba::Cli.start(["export"]) }
    end

    it "should load config and call export" do
      @result.should include "Exporting your book"
    end

    context "with selected exporter(s)" do
      pending
    end
  end

  describe "server" do
    pending
  end

  describe "help" do
    it "description" do
      pending
      # results = capture(:stdout) { Kotoba::Cli.start(["help"]) }
    end
  end
end
