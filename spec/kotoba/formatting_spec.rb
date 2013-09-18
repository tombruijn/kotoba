require "spec_helper"

class Format
  include Kotoba::Formatting
end

describe Kotoba::Formatting do
  before(:all) { @format = Format.new }

  describe ".inline_format" do
    it "should " do
      text = @format.inline_format("text", {
        font: "Helvetica",
        style: [:italic, :bold],
        color: "red",
      })
      text.should include "<b>"
      text.should include "</b>"
      text.should include "<i>"
      text.should include "</i>"
      text.should include "<font name='Helvetica'>"
      text.should include "</font>"
      text.should include "<color rgb='red'>"
      text.should include "</color>"
    end
  end
end
