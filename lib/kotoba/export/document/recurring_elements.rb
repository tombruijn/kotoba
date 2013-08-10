class Kotoba::Export::Document
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
end
