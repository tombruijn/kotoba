module Kotoba
  class Layout < Hashie::Dash
    property :page_range, :default => :all
    property :orientation, :default => :portrait # portrait/landscape
    property :size, :default => "LETTER" # Predefined prawn size
    property :width, :default => 0
    property :height, :default => 0

    attr_reader :margin, :header, :footer, :paragraph, :headings,
                :quote, :code, :list

    def initialize(args = {})
      super(args)
    end

    # Returns prawn ready page size value
    # Can be either an array with custom sizes or a Prawn predefined size
    # @see: prawnpdf/prawn/blob/master/lib/prawn/document/page_geometry.rb
    #
    # @return [Array/String] Prawn compatible size value
    #
    def page_size
      if width > 0 && height > 0
        [width, height]
      else
        size
      end
    end

    # @return [Float] width of the page in PDF points
    #
    def page_width
      width, height = array_page_sizes
      width
    end

    # @return [Float] height of the page in PDF points
    #
    def page_height
      width, height = array_page_sizes
      height
    end

    # Returns the width of the page's content
    # The content area is the size of page minus its inner and outer margins
    #
    # @return [Float] width of the content area/bounding box
    #
    def content_width
      page_width - margin.inner - margin.outer
    end

    def margin
      @margin ||= Margin.new
      yield(@margin) if block_given?
      @margin
    end

    def header
      @header ||= RecurringElement.new(page_range)
      yield(@header) if block_given?
      @header
    end

    def footer
      @footer ||= RecurringElement.new(page_range)
      yield(@footer) if block_given?
      @footer
    end

    def default
      @default ||= DefaultStyling.new(page_range)
      yield(@default) if block_given?
      @default
    end

    def paragraph
      @paragraph ||= Paragraph.new
      yield(@paragraph) if block_given?
      @paragraph
    end

    def heading(i)
      @headings ||= Hash.new { |hash,i| hash[i] = Styling.new(page_range) }
      yield(@headings[i]) if block_given?
      @headings[i]
    end

    def quote
      @quote ||= Styling.new(page_range)
      yield(@quote) if block_given?
      @quote
    end

    def code
      @code ||= Styling.new(page_range)
      yield(@code) if block_given?
      @code
    end

    def list
      @list ||= Styling.new(page_range)
      yield(@list) if block_given?
      @list
    end

    # Returns a hash with keys and values that should be given to prawn
    # on new page creation.
    # The left and right margins can differ for every page, depending if they
    # have odd or even page numbers. This is used for inner and outer margins.
    #
    # @param page_number [Integer] page number for which page it should be.
    #
    # @return [Hash] hash with prawn values
    #
    def to_h(page_number)
      {
        page_size: page_size,
        size: page_size,
        orientation: orientation,
        top_margin: margin.top,
        bottom_margin: margin.bottom
      }.tap do |hash|
        if page_number.even?
          hash[:left_margin] = margin.outer
          hash[:right_margin] = margin.inner
        else
          hash[:left_margin] = margin.inner
          hash[:right_margin] = margin.outer
        end
      end
    end

    protected

    # Returns an array with width and height values of the page
    # Asks prawn for the width and height if a prawn default size is used
    #
    # @return [Array] array with floats that represent the width and height of
    #  the page
    #
    def array_page_sizes
      if page_size.is_a?(Array)
        page_size
      else
        Prawn::Document::PageGeometry::SIZES[size]
      end
    end
  end
end

require "kotoba/layout/margin"
require "kotoba/layout/styling"
require "kotoba/layout/paragraph"
require "kotoba/layout/recurring_element"
