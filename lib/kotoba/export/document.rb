module Kotoba
  module Export
    class Document < Prawn::Document
      include Kotoba::Export::Helpers::Positioning

      attr_accessor :headings, :sections

      def initialize(options={}, &block)
        @sections = []
        @headings = []
        super(page_options.merge(config.to_h).merge(options), &block)
      end

      # Starts a new page in the Prawn document
      #
      # @see Prawn::Document's start_new_page method
      #
      def start_new_page(options={})
        super(page_options.merge(options))
      end

      # Returns a hash with options for page creation.
      # The values depend on the defined layout for the to be created page.
      #
      # @return [Hash] hash with page options
      #
      def page_options
        page_layout = layout_for_next_page
        current_page_count = page_number || 1
        page_options = if current_page_count.odd?
          {
            :left_margin => page_layout.margin.outer,
            :right_margin => page_layout.margin.inner
          }
        else
          {
            :left_margin => page_layout.margin.inner,
            :right_margin => page_layout.margin.outer
          }
        end
        page_options.merge(page_layout.to_h)
      end

      # Adds recurring elements to all pages.
      # Asks the layout for that page if there is any recurring elements
      # and adds them if this is the case.
      # The content can be page numbering and custom content.
      #
      def add_recurring_elements!
        (1..page_count).each do |p|
          go_to_page(p)
          add_recurring_element(:header)
          add_recurring_element(:footer)
          page_numbers_increment
        end
      end

      # Positions and adds a recurring element to the current page if any is set.
      # Only does one element per page, call the method with the names of the
      # recurring element for multiple recurring elements.
      # Does nothing if no recurring elements are configured in the layout.
      #
      # @param element_type [Symbol] name of recurring element (header/footer)
      #
      def add_recurring_element(element_type)
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

      # Adds page number to the current page.
      # Will only add page number when numbering is active on the element.
      #
      # @param element [Kotoba::Layout::RecurringElement] a recurring element
      # @param options [Hash] options that position the content,
      #                       see bounding_box_on.
      #                       Requires the options :page_number and :page_count
      #                       as well.
      #
      def numbering_for_recurring_element(element, options={})
        numbering = element.numbering
        return unless numbering.active
        counter = set_page_counter(numbering)
        bounding_box_on(options) do
          text numbering.format(counter[:number], counter[:total]),
            :align => numbering.align
        end
      end

      # Adds custom content to the current page.
      # Used to add recurring content such as headers and footers.
      # Will only add content if any is configured.
      #
      # @param element [Kotoba::Layout::RecurringElement] a recurring element
      # @param options [Hash] options that position the content,
      #                       see bounding_box_on
      #
      def content_for_recurring_element(element, options={})
        return unless element.content
        bounding_box_on(options) do
          element.content.call(self)
        end
      end

      # Creates a bounding box at a given top position.
      # It places it at the given top coordinate and left coordinate depending on
      # the page number (even/odd) and layout.
      # A block must be given to be executed inside the bounding box.
      #
      # @param options [Hash] options hash. Expected keys:
      #                                           :top (proc that returns number)
      #                                           :width (number)
      #                                           :height (number)
      # @yield block that should be called inside the bounding box
      #
      def bounding_box_on(options={})
        canvas do
          bounding_box([left_position, options[:top].call], options) do
            yield
          end
        end
      end

      # Adds an outline to the prawn document.
      # Makes navigation of the document easier.
      #
      def outline!
        outline_chapter_headings(@headings)
      end

      # Returns the current page number.
      # When no page is created yet it will return 1 instead of nil or 0
      # (prawn default for page_number).
      #
      # @return [Integer] current page number
      #
      def current_page_number
        return 1 if page_is_first_page?
        page_number
      end

      # Returns a boolean indicating if the current page is the first page
      # or the first to be created page.
      #
      # @return [Boolean] true page is first page, false page is no first page
      #
      def page_is_first_page?
        [0, nil].include?(page_number)
      end

      # Returns the layout for the current page
      #
      # @return [Kotoba::Layout] the layout specified for the next page
      #
      def layout
        config.layout_for_page(current_page_number)
      end

      # Returns the layout for the next page.
      # Used for page creation in start_new_page.
      #
      # @return [Kotoba::Layout] the layout specified for the next page
      #
      def layout_for_next_page
        next_page_number = page_is_first_page? ? 1 : (page_number + 1)
        config.layout_for_page(next_page_number)
      end

      def config
        Kotoba.config
      end

      def book
        Kotoba.book
      end

      protected

      # Increments all known page numbering systems registered in @page_counters.
      #
      def page_numbers_increment
        return unless @page_counters
        @page_counters.each_pair do |key, value|
          @page_counters[key][:number] += 1
        end
      end

      # Creates the page numbering with defaults for the given numbering.
      # configuration. Sets page numbers and totals based on the.
      # start_count_at or document defaults.
      #
      # @param [Kotoba::Layout::RecurringElement::PageNumbering]
      #        numbering configuration used for this numbering system
      #
      # @return [Hash] Hash containing details for page numbering
      #                {number: 1, total: 2}
      #
      def set_page_counter(numbering)
        # Used to register all page numbering systems active
        @page_counters ||= Hash.new { |hash, key| hash[key] = { number: 1 } }
        counter = @page_counters[numbering.object_id]
        custom_numbering = counter[:number] == 1 &&
                           numbering.start_count_at.nonzero?
        # First time page numbering is called
        if custom_numbering
          # Start on custom page number
          counter[:number] = numbering.start_count_at
          # Total pages based on the current page and start_count_at
          counter[:total] = page_count + numbering.start_count_at - page_number
        elsif !counter.key?(:total)
          # Starts without custom page number, uses prawn defaults
          counter[:total] = page_count
        end
        counter
      end

      # Tells Prawn the outline of the document, a table of contents.
      # Will automatically nest chapters as long as the nesting is
      # done in advance and nested chapters are stored in the chapter's
      # children key as an array.
      #
      # @param list [Array] array with hashes that represent headings
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
end
