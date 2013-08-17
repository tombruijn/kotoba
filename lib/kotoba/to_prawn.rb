module MaRuKu::Out::Prawn
  # Prawn document, is called to add content
  attr_reader :prawn
  # Integer value that counts the number of paragraphs in one section
  # @see to_paragraph
  attr_reader :paragraph_count

  # Reads the interpreted markdown and writes text/elements as configured in the
  # layout for the current page.
  #
  # @param prawn [Prawn::Document] document the markdown should be added to
  #
  def to_prawn(prawn)
    @prawn = prawn
    @paragraph_count = 0
    array_to_prawn(@children)
  end

  # Loops through maruku elements and calls to_prawn_* methods based on which
  # markdown element they are. If an element is a string it added to the end
  # result. If it is an unknown/unsupported type it adds nothing to the result.
  #
  # @example
  #   element = MaRuKu::MDElement.new (node_type => :header)
  #   array_to_prawn([element])
  #
  #   # => will call to_prawn_header(element)
  #
  # @todo The result array functionality should be added to to(_filtered)_text
  # @param array [Array] array of maruku elements
  # @return [Array] array of strings (Would only rely on the result if
  #  an array of only strings is given. Prawn is meant to enter it.)
  #
  def array_to_prawn(array)
    result = []
    array.each do |element|
      if element.kind_of?(String)
        result << element
      elsif element.kind_of?(MaRuKu::MDElement)
        method = "to_prawn_#{element.node_type}"
        next unless element.respond_to?(method)

        prawn_element = send(method, element)
        result << prawn_element
      end
    end
    result
  end

  # Converts HTML entities to their original entities.
  # To counter act a side effect of Maruku which prepares to generate HTML with
  # HTML entities &quot; etc.
  #
  # @param entity [MaRuKu::MDElement] entity element for special entities
  #
  def to_prawn_entity(entity)
    html = entity.to_html_entity
    HTMLEntities.new.decode(html)
  end

  # Adds the given paragraph to the prawn document
  # with the configured layout for the current page.
  # Counts the number of paragraphs and applies 'book indenting' on the first
  # paragraph if the configuration is active.
  #
  # @param paragraph [MaRuKu::MDElement] element with paragraph data
  #
  def to_prawn_paragraph(paragraph)
    @paragraph_count += 1
    options = options_for_paragraph(@paragraph_count)
    prawn.text to_text(paragraph.children), options
  end

  # Adds text to the prawn document styled as a heading
  # It uses the styling for the selected heading level
  #
  # The heading is also saved in the headings list
  # to build an PDF outline and Table of Contents later on
  #
  # @param header [MaRuKu::MDElement] header element
  #
  def to_prawn_header(header)
    options = options_for(:heading, header.level)
    prawn.text to_text(header.children), options

    prawn.register_heading({
      :name => to_text(header.children),
      :level => header.level,
      :page => prawn.page_count
    })
  end

  # Adds an ordered list
  #
  # @param ol [MaRuKu::MDElement] ordered list element
  #
  def to_prawn_ol(ol)
    @li_i = 0
    ol.children.each do |li|
      @li_i += 1
      prawn.text "#{@li_i}. #{to_text(li.children)}"
    end
  end

  # Adds an unordered list
  #
  # @param ul [MaRuKu::MDElement] unordered list element
  #
  def to_prawn_ul(ul)
    ul.children.each do |li|
      prawn.text "- #{to_text(li.children)}"
    end
  end

  def to_prawn_code(code)
    # prawn.text "<code>#{code}</code>"
  end

  def to_prawn_quote(quote)
    # prawn.text "<quote>#{quote}</quote>"
  end

  # Adds a horizontal rule on the current position of the prawn cursor.
  #
  # @todo Add styling functionality.
  #
  # @param hrule [MaRuKu::MDElement] horizontal rule element
  #
  def to_prawn_hrule(hrule = nil)
    prawn.stroke_horizontal_rule
  end

  def to_prawn_ref_definition(ref_definition)
    # prawn.text "ref_definition"
  end

  def to_prawn_link(link)
    # prawn.text link.to_html
  end

  # TODO: What is this?
  def to_prawn_im_link(link)
    # prawn.text link.to_html
  end

  # Adds text with emphasis.
  # Uses prawn's inline formatting.
  #
  # @param e [MaRuKu::MDElement] emphasis element
  #
  def to_prawn_emphasis(e)
    "<i>#{to_text(e.children)}</i>"
  end

  # Adds bold text.
  # Uses prawn's inline formatting.
  #
  # @param e [MaRuKu::MDElement] bold text element
  #
  def to_prawn_strong(e)
    "<b>#{to_text(e.children)}</b>"
  end

  def to_prawn_inline_code(e)
    prawn_inline_formatting_for(:code, e.raw_code)
  end

  def to_prawn_div(div)
    # prawn.text div
  end

  protected

  # @param elements [Array] Array of objects that listen to a .to_s call
  # @return [String] joined string of elements
  #
  def to_text(elements)
    array_to_prawn(elements).join("")
  end

  def prawn_inline_formatting_for(element_type, element)
    layout = layout_for(element_type)

    if layout.style.include?(:italic) || layout.style.include?("italic")
      element = "<i>#{element}</i>"
    end
    if layout.style.include?(:bold) || layout.style.include?("bold")
      element = "<b>#{element}</b>"
    end
    element = "<color rgb='#{layout.color}'>#{element}</color>"
    element = "<font name='#{layout.font}' size='#{layout.size}' "\
      "character_spacing='#{layout.character_spacing}'>#{element}</font>"
    element
  end

  # Returns the layout configuration for a specific element type
  #
  # @param element [Symbol] element type
  # @param selector [Object] sub selector for type (e.g. 1 for heading level 1)
  # @return [Object] a Kotoba::Layout subclass
  #
  def layout_for(element, selector=nil)
    layout = Kotoba.config.layout_for_page(prawn.page_number)
    if selector
      layout.send(element, selector)
    else
      layout.send(element)
    end
  end

  def options_for(element, selector=nil)
    options = layout_for(element, selector).to_hash
    options.merge(:inline_format => true)
  end

  def options_for_paragraph(i)
    options = options_for(:default)

    paragraph_config = layout_for(:paragraph)
    paragraph_options = options_for(:paragraph)

    # Normal paragraph indenting
    indent = paragraph_config.indent
    # Book indent: Do not indent first paragraph in section
    if paragraph_config.book_indent
      indent = indent && i > 1
    end

    options.merge!(paragraph_options) if indent
    options
  end
end

MaRuKu::MDElement.send(:include, MaRuKu::Out::Prawn)
