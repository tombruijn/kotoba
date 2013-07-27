require "spec_helper"

describe MaRuKu::Out::Prawn do
  let(:text) { "" }
  let(:prawn) { Kotoba::Document.new }
  let(:out) { Maruku.new(text) }

  describe ".to_prawn" do
    it "should set prawn" do
      out.to_prawn(prawn)
      out.prawn.should == prawn
    end

    it "should reset paragraph count" do
      out.paragraph_count.should be_nil
      out.to_prawn(prawn)
      out.paragraph_count.should == 0
    end

    it "should initiate the conversion of Markdown to prawn" do
      out.should_receive(:array_to_prawn).with(kind_of(Array))
      out.to_prawn(prawn)
    end

    context "render" do
      let(:text) { "test string for render" }

      it "should render them" do
        out.to_prawn(prawn)
        first_page = PDF::Inspector::Page.analyze(prawn.render).pages.first
        first_page[:strings].should include "test string for render"
      end
    end
  end

  describe ".array_to_prawn" do
    before { out.stub(:options_for => {}) }
    subject { out.array_to_prawn(array) }

    context "with strings" do
      let(:array) { ["i ", "am ", "a ", "string"] }

      it "should do nothing with strings" do
        should == array
      end
    end

    context "with Maruku elements" do
      context "known node types" do
        let(:array) { Maruku.new("# header").children }

        it "should call specific Maruku::Out methods" do
          array.first.node_type.should == :header
          out.should_receive(:to_prawn_header).with(array.first)
          subject
        end
      end

      pending "unknown node types"
    end

    context "with other elements" do
      let(:array) { [Hash.new, Array.new, Object, Maruku, Kotoba] }

      it "should skip the element" do
        should == []
      end
    end
  end

  describe ".to_text" do
    subject { out.send(:to_text, ["a", "2"]) }

    it "should combine join the elements" do
      should == "a2"
    end
  end

  describe "element methods" do
    subject { prawn }

    describe ".to_prawn_header" do
      let(:text) { "# header" }

      it { subject.should_receive(:text).with("header", kind_of(Hash)) }

      describe "outline creation" do
        let(:text) do
          "# heading 1\n\n## heading 2.1\n\n## heading 2.2\n\n"\
          "### heading 3\n\n# heading 1"
        end
        before { out.to_prawn(prawn) }

        it "should add chapters headings to outline" do
          heading_1 = subject.headings.first
          heading_2_1 = heading_1[:children].first
          heading_2_2 = heading_1[:children].last
          heading_3 = heading_2_2[:children].first
          heading_4 = subject.headings.last

          heading_1.should == {
            name: "heading 1",
            level: 1,
            page: 1,
            children: [heading_2_1, heading_2_2]
          }
          heading_2_1.should == {
            name: "heading 2.1",
            level: 2,
            page: 1,
            children: [],
            parent: heading_1
          }
          heading_2_2.should == {
            name: "heading 2.2",
            level: 2,
            page: 1,
            children: [heading_3],
            parent: heading_1
          }
          heading_3.should == {
            name: "heading 3",
            level: 3,
            page: 1,
            children: [],
            parent: heading_2_2
          }
          heading_4.should == {
            name: "heading 1",
            level: 1,
            page: 1,
            children: []
          }
        end
      end
    end

    describe ".to_prawn_paragraph" do
      let :paragraph_one do
        "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do"
      end
      let :paragraph_two do
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui"
      end
      let :text do
        "#{paragraph_one}\n\n#{paragraph_two}"
      end

      context "with two paragraphs" do
        it "should create seperate paragraphs" do
          subject.should_receive(:text).
            with(paragraph_one.gsub("\n", " "), kind_of(Hash))
          subject.should_receive(:text).
            with(paragraph_two.gsub("\n", " "), kind_of(Hash))
        end
      end
    end

    describe ".to_prawn_emphasis" do
      context "*" do
        let(:text) { "*emphasis*" }

        it {
          subject.should_receive(:text).with("<i>emphasis</i>", kind_of(Hash))
        }
      end

      context "_" do
        let(:text) { "_emphasis_" }

        it {
          subject.should_receive(:text).with("<i>emphasis</i>", kind_of(Hash))
        }
      end
    end

    describe ".to_prawn_strong" do
      context "**" do
        let(:text) { "**strong**" }

        it {
          subject.should_receive(:text).with("<b>strong</b>", kind_of(Hash))
        }
      end

      context "__" do
        let(:text) { "__strong__" }

        it {
          subject.should_receive(:text).with("<b>strong</b>", kind_of(Hash))
        }
      end
    end

    describe ".to_prawn_entity" do
      context "quotes" do
        let(:text) {
          HTMLEntities.new.encode("'\"text\"").force_encoding("UTF-8")
        }

        it { subject.should_receive(:text).with("'\"text\"", kind_of(Hash)) }
      end

      pending "more dangerous UTF-8 entities"
    end

    describe ".to_prawn_hrule" do
      context "---" do
        let(:text) { "---" }

        it { subject.should_receive(:stroke_horizontal_rule) }
      end

      context "* * *" do
        let(:text) { "* * *" }

        it { subject.should_receive(:stroke_horizontal_rule) }
      end

      context "***" do
        let(:text) { "***" }

        it { subject.should_receive(:stroke_horizontal_rule) }
      end

      context "- - -" do
        let(:text) { "- - -" }

        it { subject.should_receive(:stroke_horizontal_rule) }
      end
    end

    pending ".to_prawn_ol"
    describe ".to_prawn_ul" do
      let(:text) { "\n- one\n- two\n- three\n" }

      it "should every list item" do
        subject.should_receive(:text).with("- one")
        subject.should_receive(:text).with("- two")
        subject.should_receive(:text).with("- three")
      end
    end

    pending ".to_prawn_code"
    pending ".to_prawn_quote"
    pending ".to_prawn_ref_definition"
    pending ".to_prawn_link"
    pending ".to_prawn_im_link"

    describe ".to_prawn_inline_code" do
      let(:text) { "normal text `inline code` more text" }

      it "should call inline formatting" do
        out.stub(:prawn_inline_formatting_for => "<style>inline code</style>")
        subject.should_receive(:text).
          with(
            "normal text <style>inline code</style> more text",
            kind_of(Hash)
          )
      end
    end

    pending ".to_prawn_div"
    pending "for all methods, see: https://github.com/bhollis/maruku/blob/master/lib/maruku/output/to_html.rb"

    after { out.to_prawn(prawn) }
  end

  describe ".wrap_around_prawn_inline_formatting_for" do
    let(:inline_code) { "inline code" }
    before do
      prawn.config.layout_for(1).code.stub(
        :style => [:italic, :bold],
        :color => "FFAE00",
        :font => "My-Font",
        :size => 13.pt,
        :character_spacing => 2.5
      )
      out.stub(:prawn => prawn)
    end
    subject { out.send(:prawn_inline_formatting_for, :code, inline_code) }

    it "should wrap inline style tags around elment" do
      subject.should ==
        "<font name='My-Font' size='13' character_spacing='2.5'>"\
        "<color rgb='FFAE00'><b><i>inline code</i></b></color></font>"
    end

    pending "sub"
    pending "sup"
    pending "strikethrough"
    pending "u"
  end

  pending ".layout_for"
  pending ".options_for"
  pending ".options_for_paragraph"
end
