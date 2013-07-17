module Kotoba
  class Document < Prawn::Document
    attr_accessor :headings, :sections

    def initialize(options={}, &block)
      @sections = []
      @headings = []
      super(options, &block)
    end

    def start_new_page(options={})
      margins = if page_count.odd?
        {
          :left_margin => layout.margin.outer,
          :right_margin => layout.margin.inner
        }
      else
        {
          :left_margin => layout.margin.inner,
          :right_margin => layout.margin.outer
        }
      end
      super(margins.merge(options))
    end

    def page_numbering!
      page_numbering_for :header, layout.header
      page_numbering_for :footer, layout.footer
    end

    def page_numbering_for(element_type, element)
      numbering = element.page_numbering
      if numbering.active
        number_pages numbering.string, {
          :at => element_type == :header ? header_position : footer_position,
          :width => layout.content_width,
          :align => numbering.align,
          :start_count_at => numbering.offset,
          :color => element.color
        }
      end
    end

    def header_position
      Proc.new do |array_index|
        array_index==0 ? left_position : header_top_position
      end
    end

    def header_top_position
      layout.page_height - layout.margin.bottom
    end

    def footer_position
      Proc.new do |array_index|
        array_index==0 ? left_position : footer_top_position
      end
    end

    def footer_top_position
      0
    end

    def left_position
      if page_number.even?
        -(layout.margin.inner - layout.margin.outer)
      else
        0
      end
    end

    def header!
      repeat(:all, :dynamic => true) do
        if layout.header.content
          bounding_box(
            [left_position, header_top_position],
            :width => layout.content_width,
            :height => layout.margin.bottom
          ) do
            layout.header.content.call(self)
          end
        end
      end
    end

    def footer!
      repeat(:all, :dynamic => true) do
        if layout.footer.content
          bounding_box(
            [left_position, footer_top_position],
            :width => layout.content_width,
            :height => layout.margin.bottom
          ) do
            layout.footer.content.call(self)
          end
        end
      end
    end

    # Adds an outline to the prawn document
    # Makes navigation of the document easier
    #
    def outline!
      outline_chapter_headings(@headings)
    end

    def config
      Kotoba.config
    end

    def layout
      config.layout_for_page(page_number)
    end

    def book
      Kotoba.book
    end

    private

    # Tells Prawn the outline of the document, a table of contents.
    # Will automatically nest chapters as long as the nesting is
    # done in advance and nested chapters are stored in the chapter's
    # children key as an array.
    #
    # @param [Array] array with hashes that represent headings
    #                {name: "Chapter 1", level: 1, page: 1, children: [Hash]}
    #
    def outline_chapter_headings(list)
      list.each do |heading|
        if heading[:children].empty?
          outline.page(:title => heading[:name], :destination => heading[:page])
        else
          outline.section(heading[:name], :destination => heading[:page]) do
            outline_chapter_headings(heading[:children])
          end
        end
      end
    end
  end
end
