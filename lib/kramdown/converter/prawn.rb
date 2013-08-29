module Kramdown::Converter
  class Prawn < Base
    # Prawn document, is called to add content
    attr_reader :prawn
    # Integer value that counts the number of paragraphs in one section
    # @see convert_p
    attr_reader :paragraph_count

    def initialize(root, options, prawn)
      super(root, options)
      @prawn = prawn
      @indent = 2
      reset_paragraph_count
    end

    def self.convert(tree, options = {}, prawn)
      options = options.merge(tree.options[:options] || {})
      converter = new(tree, ::Kramdown::Options.merge(options), prawn)
      result = converter.convert(tree)
      result.encode!(tree.options[:encoding]) if result.respond_to?(:encode!)
      [result, converter.warnings]
    end

    def convert(el, options = {})
      send("convert_#{el.type}", el, options)
    end

    def convert_blank(el, options = {})
    end

    def convert_text(el, options = {})
      el.value
    end

    def convert_p(el, options = {})
      @paragraph_count += 1
      indent = options.delete(:indent_paragraphs)
      reset_paragraph_count if indent === false

      style = style_for_paragraph(@paragraph_count, indent)
      style.merge(options)
      prefix = format_prefix(options[:prefix])
      prawn.text "#{prefix}#{convert_children(el.children).join}", style
    end

    def convert_codespan(el, options = {})
      inline_formatting_for(:code, el, options)
    end

    def convert_codeblock(el, options = {})
      style = style_for(:code)
      prawn.text el.value, style
    end

    def convert_blockquote(el, options = {})
      style = style_for(:quote)
      convert_children(el.children,
        indent_paragraphs: style[:indent_paragraphs])
    end

    def convert_header(el, options = {})
      style = style_for(:heading, el.options[:level])
      text = convert_children(el.children).join
      prawn.text text, style

      prawn.register_heading(
        name: strip_tags(text),
        level: el.options[:level],
        page: prawn.page_count
      )
    end

    def convert_hr(el, options = {})
      prawn.stroke_horizontal_rule
    end

    def convert_ul(el, options = {})
      @ol_index = 0
      prefix = ""
      prefix = "{n}. " if el.type == :ol
      prefix = "- " if el.type == :ul
      convert_children(el.children, { prefix: prefix })
    end
    alias :convert_ol :convert_ul
    alias :convert_dl :convert_ul

    def convert_li(el, options = {})
      @ol_index += 1
      style = style_for(:list).to_h.merge(prefix: options[:prefix])
      convert_children(el.children, style)
    end
    alias :convert_dd :convert_li

    def convert_dt(el, options = {})
    end

    def convert_html_element(el, options = {})
    end

    def convert_xml_comment(el, options = {})
    end
    alias :convert_xml_pi :convert_xml_comment

    def convert_table(el, options = {})
    end
    alias :convert_thead :convert_table
    alias :convert_tbody :convert_table
    alias :convert_tfoot :convert_table
    alias :convert_tr :convert_table

    def convert_td(el, options = {})
    end

    def convert_comment(el, options = {})
    end

    def convert_br(el, options = {})
    end

    def convert_a(el, options = {})
      "<link href='#{URI.escape(el.attr["href"], /'/)}'>"\
      "#{convert_children(el.children).join}</link>"
    end

    def convert_img(el, options = {})
    end

    def convert_footnote(el, options = {})
    end

    def convert_raw(el, options = {})
    end

    def convert_em(el, options = {})
      tag = el.type == :em ? :i : :b
      "<#{tag}>#{convert_children(el.children).join}</#{tag}>"
    end
    alias :convert_strong :convert_em

    def convert_entity(el, options = {})
      ::Kramdown::Utils::Entities.entity(el.value.to_s).char
    end
    alias :convert_smart_quote :convert_entity

    def convert_typographic_sym(el, options = {})
    end

    def convert_math(el, options = {})
    end

    def convert_abbreviation(el, options = {})
    end

    def convert_root(el, options = {})
      convert_children(el.children)
    end

    protected

    def convert_children(children, options = {})
      results = []
      children.each do |child|
        results << convert(child, options)
      end
      results
    end

    def inline_formatting_for(element_type, el, options = {})
      layout = layout_for(element_type)

      if layout.style.include?(:italic) || layout.style.include?("italic")
        element = "<i>#{element}</i>"
      end
      if layout.style.include?(:bold) || layout.style.include?("bold")
        element = "<b>#{element}</b>"
      end
      element = "<color rgb='#{layout.color}'>#{element}</color>"
      element = "<font name='#{layout.font}' size='#{layout.size}' "\
        "character_spacing='#{layout.character_spacing}'>#{el.value}</font>"
      element
    end

    # Returns the layout configuration for a specific element type
    #
    # @param element [Symbol] element type
    # @param selector [Object] sub selector for type (e.g. 1 for heading level 1)
    # @return [Object] a Kotoba::Layout subclass
    #
    def layout_for(element, selector = nil)
      layout = Kotoba.config.layout_for_page(prawn.page_number)
      if selector
        layout.send(element, selector)
      else
        layout.send(element)
      end
    end

    def style_for(element, selector = nil)
      layout_for(element, selector).to_h.merge(inline_format: true)
    end

    def style_for_paragraph(i, fixed_indent = nil)
      options = layout_for(:default).to_h.merge(inline_format: true)
      if fixed_indent
        options.merge!(indent_paragraphs: fixed_indent)
      else
        style = layout_for(:paragraph)
        # Normal paragraph indenting
        indent = style.indent
        # Book indent: Do not indent first paragraph in section
        if style.book_indent
          indent = indent && i > 1
        end
        options.merge!(style.to_h) if indent
      end
      options
    end

    def reset_paragraph_count
      @paragraph_count = 0
    end

    def format_prefix(prefix)
      (prefix || "").gsub("{n}", @ol_index.to_s)
    end

    def strip_tags(string)
      string.gsub(/<[^>]+>([^<\/]+)<\/[^>]+>/, '\1')
    end
  end
end
