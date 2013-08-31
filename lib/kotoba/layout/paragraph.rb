class Kotoba::Layout
  class Paragraph < Hashie::Dash
    # Boolean value to set indenting on/off on paragraphs.
    property :indent, :default => true
    # PDF points with which indent.
    property :indent_with, :default => 5.mm
    # Book indenting will not indent every first paragraph of a section.
    property :book_indent, :default => true

    # Returns true/false if the paragraph should be indented.
    # It takes into consideration which paragraph it is (see @param
    # paragraph_number) and which indenting options are activated.
    #
    # @see book_indent option about why paragraph_number is important.
    # @param paragraph_number [Integer] paragraph to check.
    # @return [Boolean]
    #
    def indent?(paragraph_number)
      # Normal paragraph indenting
      answer = indent
      # Book indent: Do not indent first paragraph in a section
      if book_indent
        answer = answer && paragraph_number > 1
      end
      answer
    end

    # @return [Hash] Hash containing indent_with value.
    #
    def to_h
      {}.tap do |hash|
        hash[:indent_paragraphs] = indent_with if indent
      end
    end
  end
end
