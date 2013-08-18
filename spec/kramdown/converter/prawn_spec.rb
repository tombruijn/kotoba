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
