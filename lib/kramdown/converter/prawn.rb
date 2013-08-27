module Kramdown::Converter
  class Prawn < Base
    attr_accessor :prawn

    def initialize(root, options, prawn)
      super(root, options)
      @prawn = prawn
      @indent = 2
    end

    def self.convert(tree, options = {}, prawn)
      options = options.merge(tree.options[:options] || {})
      converter = new(tree, ::Kramdown::Options.merge(options), prawn)
      result = converter.convert(tree)
      result.encode!(tree.options[:encoding]) if result.respond_to?(:encode!)
      [result, converter.warnings]
    end

    def convert(el)
      send("convert_#{el.type}", el)
    end

    def convert_blank(el)
    end

    def convert_text(el)
      el.value
    end

    def convert_p(el)
      options = options_for(:paragraph)
      prawn.text convert_children(el.children).join, options
    end

    def convert_codespan(el)
      inline_formatting_for(:code, el)
    end

    def convert_codeblock(el)
      prawn.text el.value, options_for(:code)
    end

    def convert_blockquote(el)
    end

    def convert_header(el)
    end

    def convert_hr(el)
      prawn.stroke_horizontal_rule
    end

    def convert_ul(el)
    end
    alias :convert_ol :convert_ul
    alias :convert_dl :convert_ul

    def convert_li(el)
    end
    alias :convert_dd :convert_li

    def convert_dt(el)
    end

    def convert_html_element(el)
    end

    def convert_xml_comment(el)
    end
    alias :convert_xml_pi :convert_xml_comment

    def convert_table(el)
    end
    alias :convert_thead :convert_table
    alias :convert_tbody :convert_table
    alias :convert_tfoot :convert_table
    alias :convert_tr :convert_table

    def convert_td(el)
    end

    def convert_comment(el)
    end

    def convert_br(el)
    end

    def convert_a(el)
    end

    def convert_img(el)
    end

    def convert_footnote(el)
    end

    def convert_raw(el)
    end

    def convert_em(el)
      tag = el.type == :em ? :i : :b
      "<#{tag}>#{convert_children(el.children).join}</#{tag}>"
    end
    alias :convert_strong :convert_em

    def convert_entity(el)
      ::Kramdown::Utils::Entities.entity(el.value.to_s).char
    end
    alias :convert_smart_quote :convert_entity

    def convert_typographic_sym(el)
    end

    def convert_math(el)
    end

    def convert_abbreviation(el)
    end

    def convert_root(el)
      convert_children(el.children)
    end

    protected

    def convert_children(children)
      results = []
      children.each do |child|
        results << convert(child)
      end
      results
    end

    def inline_formatting_for(element_type, el)
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
    def layout_for(element, selector=nil)
      layout = Kotoba.config.layout_for_page(prawn.page_number)
      if selector
        layout.send(element, selector)
      else
        layout.send(element)
      end
    end

    def options_for(element, selector=nil)
      layout_for(element).to_h.merge(inline_format: true)
    end
  end
end
