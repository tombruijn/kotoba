require "spec_helper"

describe Kotoba::Parser do
  let(:parser) { Kotoba::Parser.new }
  before :all do
    @chapter_dir = File.join(Kotoba::BOOK_DIR, "chapters", "chapter_1")
  end

  describe ".collect" do
    let(:file) do
      File.join(Kotoba::BOOK_DIR, "chapters", "chapter_1", "intro_file.md")
    end
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
  pending ".read_file"
end
