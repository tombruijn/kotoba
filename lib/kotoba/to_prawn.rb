module MaRuKu::Out::Prawn
  attr_reader :prawn, :paragraph_count

  def to_prawn(prawn)
    @prawn = prawn
    @paragraph_count = 0
    array_to_prawn(@children)
  end

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

  def to_text(elements)
    array_to_prawn(elements).join("")
  end

  def to_prawn_paragraph(paragraph)
    @paragraph_count += 1
    options = options_for_paragraph(@paragraph_count)

    prawn.text to_text(paragraph.children), options
  end

  def to_prawn_entity(entity)
    html = entity.to_html_entity
    decoded = HTMLEntities.new.decode(html)
    decoded
  end

  # Adds text to the prawn document styled as a heading
  # It uses the styling for the selected heading level
  #
  # The heading is also saved in the headings list
  # to build an PDF outline and Table of Contents later on
  #
  def to_prawn_header(header)
    options = options_for(:heading, header.level)
    prawn.text to_text(header.children), options

    # Save heading so we can build the Table of Contents later on
    heading = {
      :name => to_text(header.children),
      :level => header.level,
      :page => prawn.page_count,
      :children => []
    }
    parent = find_parent_heading_for_level(@last_heading, header.level)
    if parent
      # Heading is sub heading
      heading[:parent] = parent
      parent[:children] << heading
    else
      # Heading is root level heading
      prawn.headings << heading
    end
    @last_heading = heading
  end

  def to_prawn_ol(ol)
    # prawn.text "ol"
  end

  def to_prawn_ul(ul)
    # prawn.text "ul"
  end

  def to_prawn_code(code)
    # prawn.text "<code>#{code}</code>"
  end

  def to_prawn_quote(quote)
    # prawn.text "<quote>#{quote}</quote>"
  end

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

  def to_prawn_emphasis(e)
    "<i>#{to_text(e.children)}</i>"
  end

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

  # Finds the parent heading for the given level
  # Will move up the tree to find the parent of the heading level
  # If no parent is found the heading is root
  #
  # @return [Hash, nil] the found parent (if any)
  #
  def find_parent_heading_for_level(heading, level)
    return if heading.nil?
    if heading[:level] == level - 1
      heading
    else
      find_parent_heading_for_level(heading[:parent], level)
    end
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

  def layout_for(element, selector = nil)
    if selector
      prawn.config.layout_for_page(prawn.page_number).send(element, selector)
    else
      prawn.config.layout_for_page(prawn.page_number).send(element)
    end
  end

  def options_for(element, selector = nil)
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
