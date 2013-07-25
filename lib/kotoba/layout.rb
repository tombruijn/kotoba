module Kotoba
  class Layout < Hashie::Dash
    property :page_range, :default => :all
    property :orientation, :default => :portrait # portrait/landscape
    property :size, :default => "LETTER" # Predefined prawn size
    property :width, :default => 0
    property :height, :default => 0

    attr_reader :margin, :header, :footer, :paragraph, :headings,
                :quote, :code

    def initialize(args = {})
      super(args)
      @margin = Margin.new
      @header = RecurringElement.new(page_range)
      @footer = RecurringElement.new(page_range)
      @default = DefaultStyling.new(page_range)
      @paragraph = Paragraph.new
      @headings = Hash.new { |hash,i| hash[i] = Styling.new(page_range) }
      @quote = Styling.new(page_range)
      @code = Styling.new(page_range)
    end

    def page_size
      if width > 0 && height > 0
        [width, height]
      else
        size
      end
    end

    def page_width
      width, height = array_page_sizes
      width
    end

    def page_height
      width, height = array_page_sizes
      height
    end

    def content_width
      page_width - margin.inner - margin.outer
    end

    def margin
      yield(@margin) if block_given?
      @margin
    end

    def header
      yield(@header) if block_given?
      @header
    end

    def footer
      yield(@footer) if block_given?
      @footer
    end

    def default
      yield(@default) if block_given?
      @default
    end

    def paragraph
      yield(@paragraph) if block_given?
      @paragraph
    end

    def heading(i)
      yield(@headings[i]) if block_given?
      @headings[i]
    end

    def quote
      yield(@quote) if block_given?
      @quote
    end

    def code
      yield(@code) if block_given?
      @code
    end

    def to_h
      {
        :page_size => page_size,
        :size => page_size,
        :orientation => orientation,
        :top_margin => margin.top,
        :bottom_margin => margin.bottom
      }
    end

    class Margin < Hashie::Dash
      property :top, :default => 2.cm
      property :bottom, :default => 2.cm
      property :inner, :default => 2.cm
      property :outer, :default => 2.cm
    end

    class Styling
      attr_reader :page_range

      OPTIONS = %w(font size color align direction character_spacing line_height
        style prefix)

      OPTIONS.each do |option|
        attr_writer option
        define_method option do
          instance_variable_get("@#{option}") || default.send(option)
        end
      end

      def initialize(page_range = :all)
        @page_range = page_range
      end

      def to_hash
        {}.tap do |hash|
          hash[:font] = font if using_prawn_font?
          hash[:size] = size
          hash[:color] = color
          hash[:style] = style unless style.empty?
          hash[:leading] = line_height
        end
      end

      protected

      def default
        Kotoba.config.layout_for_page(page_range).default
      end

      def using_prawn_font?
        Prawn::Font::AFM::BUILT_INS.include?(font)
      end
    end

    class DefaultStyling < Styling
      def initialize(*args)
        super(args)
        @font = "Times-Roman"
        @size = 12.pt
        @color = "000000"
        @align = :left # left/right/center/justify
        @direction = :ltr # ltr/rtl
        @character_spacing = 0
        @line_height = 12.pt
        @style = []
        @prefix = ""
      end
    end

    class Paragraph < Hashie::Dash
      property :indent, :default => true
      property :indent_with, :default => 5.mm
      property :book_indent, :default => true

      def to_hash
        {}.tap do |hash|
          hash[:indent_paragraphs] = indent_with if indent
        end
      end
    end

    class RecurringElement < Styling
      attr_reader :numbering
      attr_accessor :content

      def initialize(*args)
        super(args)
        @numbering = PageNumbering.new
      end

      def content(&block)
        @content = block if block_given?
        @content
      end

      def page_numbering
        yield(@numbering) if block_given?
        @numbering
      end

      class PageNumbering < Hashie::Dash
        property :active, :default => false # true/false
        property :string, :default => "<page>" # page <page> of <total>
        property :align, :default => :center # left, center, right, position
        property :start_count_at, :default => 0
        property :document_page_number, :default => 0
        property :document_page_count, :default => 0
        property :_current_page_number, :default => 0

        # Creates a string with the current page number and page count based on
        # the string set by the user.
        #
        # Example:
        #
        #     p = PageNumbering.new
        #     p.string = "Page <page> of <total>"
        #     p.document_page_number = 1
        #     p.document_page_count = 2
        #     p.format # => "Page 1 of 2"
        #
        # @return [String] formatted string with page number and/or count
        #
        def format
          string.
            gsub("<page>", calculate_page_number.to_s).
            gsub("<total>", calculate_page_count.to_s)
        end

        protected

        # Calculates the page number of the current page
        # If start_count_at is set in the configuration it ignores the actual
        # page numbering system from the document and instead counts it using
        # its own.
        #
        # @return [Integer] current page number
        #
        def calculate_page_number
          if start_count_at.zero?
            # Using the real page numbers
            document_page_number
          else
            # Using our own page numbering count
            if _current_page_number.zero?
              # First page of this numbering starts at the given number
              _current_page_number = start_count_at
            else
              # Increment the page number
              _current_page_number += 1
            end
          end
        end

        # Calculates and returns the page count of the document
        # If start_count_at is set in the configuration it subtracts that
        # number from the total page count known.
        #
        # @return [Integer] total page count based on
        #
        def calculate_page_count
          if start_count_at.zero?
            # Using the real page numbers
            document_page_count
           else
            # Using our own page numbering count
            document_page_count - start_count_at
          end
        end
      end
    end

    protected

    def array_page_sizes
      if page_size.is_a?(Array)
        page_size
      else
        Prawn::Document::PageGeometry::SIZES[size]
      end
    end
  end
end
