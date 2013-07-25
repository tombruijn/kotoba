module Kotoba
  class Document < Prawn::Document
    attr_accessor :headings, :sections

    def initialize(options={}, &block)
      @sections = []
      @headings = []
      super(page_options.merge(options), &block)
    end

    def start_new_page(options={})
      super(page_options.merge(options))
    end

    def page_options
      current_page_count = page_number || 1
      page_options = if current_page_count.odd?
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
      page_options.merge(layout.to_h)
    end

    def add_recurring_elements!
      add_recurring_element(:header)
      add_recurring_element(:footer)
    end

    def add_recurring_element(element_type)
      repeat(:all, :dynamic => true) do
        element_layout = layout
        element = element_layout.send(element_type)
        options = if element_type == :header
          {
            :top => Proc.new { header_top_position },
            :height => element_layout.margin.top
          }
        else
          {
            :top => Proc.new { footer_top_position },
            :height => element_layout.margin.bottom
          }
        end
        options.merge!(:width => element_layout.content_width)

        numbering_for_recurring_element(element, options)
        content_for_recurring_element(element, options)
      end
    end

    def numbering_for_recurring_element(element, options={})
      numbering = element.numbering
      return unless numbering.active
      bounding_box_on(options) do
        text numbering.format(page_number, page_count), :align => numbering.align
      end
    end

    def content_for_recurring_element(element, options={})
      return unless element.content
      bounding_box_on(options) do
        element.content.call(self)
      end
    end

    # Creates a bounding box at a given top position
    # It places it at the given top coordinate and left coordinate depending on
    # the page number (even/odd) and layout.
    # A block must be given to be executed inside the bounding box
    #
    # @param [Hash] options hash. Expected keys:
    #                                           :top (proc that returns number)
    #                                           :width (number)
    #                                           :height (number)
    # @param [block] block that should be called inside the bounding box
    #
    def bounding_box_on(options={})
      canvas do
        bounding_box([left_position, options[:top].call], options) do
          yield
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
      config.layout_for_page([0, nil].include?(page_number) ? 1 : page_number)
    end

    def book
      Kotoba.book
    end

    private

    # Returns header y coordinate
    # Should be called from within a Prawn canvas block so it will return the
    # absolute top of the page rather than the top of its parent bounding_box
    #
    # @return [Integer] y coordinate for the header
    #
    def header_top_position
      bounds.top
    end

    # Returns the footer y coordinate
    # Should be called from within a Prawn canvas block so it will return the
    # correct position rather than one based on its parent bounding_box
    #
    # It takes the absolute bottom of the page and adds the bottom margin to
    # position the footer correctly
    #
    # @return [Integer] y coordinate for the footer
    #
    def footer_top_position
      bounds.bottom + layout.margin.bottom
    end

    # Returns the x position for a content box
    # Should be called from within a Prawn canvas block so it will return the
    # correct position based on the absolute left rather than the left of its
    # parent bounding_box
    #
    # @return [Integer] x coordinate for the content box
    #
    def left_position
      if page_number.even?
        bounds.left + layout.margin.outer
      else
        bounds.left + layout.margin.inner
      end
    end

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
