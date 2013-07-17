require "spec_helper"

describe Kotoba::Parser do
  let(:file) do
    File.join(Kotoba::BOOK_DIR, "chapters", "chapter_1", "intro_file.md")
  end
  let(:parser) { Kotoba::Parser.new }

  describe ".collect" do
    let(:directory) do
      File.join(Kotoba::BOOK_DIR, "chapters", "chapter_1")
    end
    before { parser.collect }
    subject { parser.files }

    it { should include file }
    it { should_not include directory }
    its(:length) { should == 2 }
  end

  pending ".create_template"

  describe ".read_file" do
    subject { parser.read_file(file) }

    it "should read the file" do
      subject.should == File.read(file)
    end

    it "should force the defined encoding" do
      Kotoba.config.encoding = "US-ASCII"
      parser.read_file(file).encoding.name.should == "US-ASCII"

      Kotoba.config.encoding = "UTF-8"
      parser.read_file(file).encoding.name.should == "UTF-8"
    end
  end
end
