require "spec_helper"

describe Kramdown::Converter::Prawn do
  let(:text) { "" }
  let(:prawn) { Kotoba::Export::Document.new }
  let(:out) { Kramdown::Document.new(text) }

  describe "text options" do
    let(:text) { "text" }

    it "should create a paragraph" do
      prawn.should_receive(:text).
        with("text", hash_including(inline_format: true))
    end
  end

  describe "plain text" do
    let(:text) { "text" }

    it "should create a paragraph" do
      prawn.should_receive(:text).with("text", kind_of(Hash))
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
      prawn.should_receive(:text).with("1. one", kind_of(Hash))
      prawn.should_receive(:text).with("2. two", kind_of(Hash))
      prawn.should_receive(:text).with("3. three", kind_of(Hash))
    end
  end

  describe ".to_prawn_ul" do
    let(:text) { "\n- one\n- two\n- three\n" }

    it "should every list item" do
      prawn.should_receive(:text).with("- one", kind_of(Hash))
      prawn.should_receive(:text).with("- two", kind_of(Hash))
      prawn.should_receive(:text).with("- three", kind_of(Hash))
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
