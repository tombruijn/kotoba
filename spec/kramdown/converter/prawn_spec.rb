require "spec_helper"

describe Kramdown::Converter::Prawn do
  let(:text) { "" }
  let(:prawn) { Kotoba::Export::Document.new }
  let(:out) { Kramdown::Document.new(text) }

  describe "text options" do
    let(:text) { "text" }

    it "should add text with inline formatting on" do
      prawn.should_receive(:text).
        with("text", hash_including(inline_format: true))
    end
  end

  describe "plain text" do
    let(:text) { "text\n\ntext\n\ntext\n\ntext" }

    it "should create a paragraph" do
      prawn.should_receive(:text).exactly(4).times.with("text", kind_of(Hash))
    end

    describe "paragraph indenting" do
      context "with book indent" do
        before :all do
          Kotoba.config.layout.paragraph do |p|
            p.indent = true
            p.indent_with = 50.mm
            p.book_indent = true
          end
        end

        it "should add alternating indenting" do
          prawn.should_receive(:text).exactly(1).times.ordered.
            with("text", hash_not_including(:indent_paragraphs))
          prawn.should_receive(:text).exactly(3).times.ordered.
            with("text", hash_including(:indent_paragraphs))
        end
      end

      context "without book indent" do
        before :all do
          Kotoba.config.layout.paragraph do |p|
            p.indent = true
            p.indent_with = 50.mm
            p.book_indent = false
          end
        end

        it "should not add book indent, but normal indent" do
          prawn.should_receive(:text).exactly(4).times.
            with("text", hash_including(:indent_paragraphs))
        end
      end

      context "without indent" do
        before(:all) { Kotoba.config.layout.paragraph.indent = false }

        it "should not add indenting options" do
          prawn.should_receive(:text).exactly(4).times.
            with("text", hash_not_including(:indent_paragraphs))
        end
      end
    end
  end

  describe "emphasis and strong text" do
    let(:text) {
      "text _emphasis text_ normal text **strong text** _emphasis, "\
      "**strong** more_"
    }

    it "should create a paragraph" do
      prawn.should_receive(:text).with(
        "text <i>emphasis text</i> normal text <b>strong text</b> "\
        "<i>emphasis, <b>strong</b> more</i>",
        kind_of(Hash))
    end
  end

  describe "code" do
    let(:text) { "normal text\n\n    code\n\nmore text" }

    it "should create code block" do
      prawn.should_receive(:text).with("normal text", kind_of(Hash)).ordered
      prawn.should_receive(:text).with(/code/, kind_of(Hash)).ordered
      prawn.should_receive(:text).with("more text", kind_of(Hash)).ordered
    end
  end

  describe "inline code" do
    let(:text) { "normal text `inline code` more text" }

    it "should call inline formatting" do
      Kramdown::Converter::Prawn.any_instance.
        stub(inline_formatting_for: "<style>inline code</style>")
      prawn.should_receive(:text).with(
        "normal text <style>inline code</style> more text",
        kind_of(Hash))
    end
  end

  describe ".to_prawn_ol" do
    let(:text) { "\n1. one\n2. two\n3. three\n" }

    it "should every list item" do
      prawn.should_receive(:text).with("1. one", kind_of(Hash)).ordered
      prawn.should_receive(:text).with("2. two", kind_of(Hash)).ordered
      prawn.should_receive(:text).with("3. three", kind_of(Hash)).ordered
    end

    context "between paragraphs" do
      let(:text) { "paragraph\n\n1. one\n2. two\n3. three\n\nend" }
      before :all do
        Kotoba.config.layout.paragraph do |p|
          p.indent = true
          p.indent_with = 50.mm
        end
      end

      it "should not add indenting to li paragraphs" do
        prawn.should_receive(:text).
          with("paragraph", hash_including(:indent_paragraphs)).ordered
        prawn.should_receive(:text).
          with("1. one", hash_not_including(:indent_paragraphs)).ordered
        prawn.should_receive(:text).
          with("2. two", hash_not_including(:indent_paragraphs)).ordered
        prawn.should_receive(:text).
          with("3. three", hash_not_including(:indent_paragraphs)).ordered
        prawn.should_receive(:text).
          with("end", hash_including(:indent_paragraphs)).ordered
      end
    end
  end

  describe ".to_prawn_ul" do
    let(:text) { "\n- one\n- two\n- three\n" }

    it "should every list item" do
      prawn.should_receive(:text).with("- one", kind_of(Hash)).ordered
      prawn.should_receive(:text).with("- two", kind_of(Hash)).ordered
      prawn.should_receive(:text).with("- three", kind_of(Hash)).ordered
    end
  end

  describe "entities" do
    let(:text) { "text & more text \" text 'something' ^ text don't" }

    it "should add entities" do
      prawn.should_receive(:text).with(
        "text & more text \u201C text \u2018something\u2019 ^ text don\u2019t",
        kind_of(Hash))
    end
  end

  describe "horizontal rule" do
    let(:text) {
      "text\n\n---\n\ntext\n\n* * *\n\ntext\n\n***\n\ntext\n\n*****\n\ntext"\
      "\n\n- - -\n\ntext\n\n---------------------------------------"
    }

    it "description" do
      prawn.should_receive(:text).with("text", kind_of(Hash)).exactly(6).times
      prawn.should_receive(:stroke_horizontal_rule).exactly(6).times
    end
  end

  after { out.to_prawn(prawn) }
end
