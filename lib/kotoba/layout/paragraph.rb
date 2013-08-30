class Kotoba::Layout
  class Paragraph < Hashie::Dash
    # Boolean value to set indenting on/off on paragraphs.
    property :indent, :default => true
    # PDF points with which indent.
    property :indent_with, :default => 5.mm
    # Book indenting will not indent every first paragraph of a section.
    property :book_indent, :default => true

    # @return [Hash] Hash containing indent_with value.
    #
    def to_h
      {}.tap do |hash|
        hash[:indent_paragraphs] = indent_with if indent
      end
    end
  end
end
