class Kotoba::Layout
  class Paragraph < Hashie::Dash
    property :indent, :default => true
    property :indent_with, :default => 5.mm
    property :book_indent, :default => true

    def to_h
      {}.tap do |hash|
        hash[:indent_paragraphs] = indent_with if indent
      end
    end
  end
end
