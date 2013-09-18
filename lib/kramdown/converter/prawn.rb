module Kramdown::Converter
  class Prawn < Base
    include Kotoba::Formatting

    # Prawn document, is called to add content
    attr_reader :prawn
    # Integer value that counts the number of paragraphs in one section
    # @see convert_p
    attr_reader :paragraph_count, :heading_count

    def initialize(root, options, prawn)
      super(root, options)
      @prawn = prawn
      reset_paragraph_count!
      @heading_count = Hash.new { |hash, key| hash[key] = 0 }
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

    def convert_p(el, inherited_style = {})
      @paragraph_count += 1

      style = if inherited_style.empty?
        style_for_paragraph(@paragraph_count)
      else
        reset_paragraph_count!
        inherited_style
      end
      style.merge!(count: inherited_style[:count] || @paragraph_count)
      write_text(to_text(el, style), style)
    end

    def convert_codespan(el, options = {})
      style = style_for(:code)
      inline_format_element(el, style)
    end

    def convert_codeblock(el, options = {})
      style = style_for(:code)
      write_text el.value, style
    end

    def convert_blockquote(el, options = {})
      style = style_for(:quote)
      convert_children(el.children, style)
    end

    def convert_header(el, options = {})
      level = el.options[:level]
      style = style_for(:heading, level)
      @heading_count[level] += 1
      text = to_text(el, style.merge(count: @heading_count[level]))
      write_text text, style

      prawn.register_heading(
        name: strip_tags(text),
        level: level,
        page: prawn.page_count
      )
    end

    def convert_hr(el, options = {})
      prawn.stroke_horizontal_rule
    end

    def convert_ul(el, options = {})
      @ol_index = 0
      style = style_for(el.type == :ol ? :ordered_list : :unordered_list)
      convert_children(el.children, style)
    end
    alias :convert_ol :convert_ul
    alias :convert_dl :convert_ul

    def convert_li(el, style = {})
      @ol_index += 1
      convert_children(el.children, style.merge(count: @ol_index))
    end
    alias :convert_dd :convert_li

    def convert_dt(el, options = {})
    end

    def convert_html_element(el, options = {})
      raise "HTML element not supported: #{el.inspect}"
    end

    def convert_xml_comment(el, options = {})
      raise "XML comment not supported: #{el.inspect}"
    end
    alias :convert_xml_pi :convert_xml_comment

    def convert_table(el, options = {})
      raise "Table not supported: #{el.inspect}"
    end
    alias :convert_thead :convert_table
    alias :convert_tbody :convert_table
    alias :convert_tfoot :convert_table
    alias :convert_tr :convert_table

    def convert_td(el, options = {})
      raise "Table cell not supported: #{el.inspect}"
    end

    def convert_comment(el, options = {})
      raise "Comment not supported: #{el.inspect}"
    end

    def convert_br(el, options = {})
      raise "BR not supported: #{el.inspect}"
    end

    def convert_a(el, options = {})
      "<link href='#{URI.escape(el.attr["href"], /'/)}'>"\
      "#{convert_children(el.children).join}</link>"
    end

    def convert_img(el, options = {})
      raise "Image not supported: #{el.inspect}"
    end

    def convert_footnote(el, options = {})
      raise "Footnote not supported: #{el.inspect}"
    end

    def convert_raw(el, options = {})
      raise "Raw not supported: #{el.inspect}"
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
      # http://kramdown.rubyforge.org/syntax.html#typographic-symbols
      # raise "Typographic Symbol not supported: #{el.inspect}"
    end

    def convert_math(el, options = {})
      raise "Math not supported: #{el.inspect}"
    end

    def convert_abbreviation(el, options = {})
      raise "Abbreviation not supported: #{el.inspect}"
    end

    def convert_root(el, options = {})
      convert_children(el.children)
    end

    protected

    def to_text(el, style)
      prefix = format_prefix(style[:prefix], style)
      "#{prefix}#{convert_children(el.children).join}"
    end

    def write_text(text, style)
      prawn.font style[:font] do
        prawn.text text, style
      end
    end

    def convert_children(children, options = {})
      results = []
      children.each do |child|
        results << convert(child, options)
      end
      results
    end

    def inline_format_element(el, style = {})
      element = if el.children.empty?
        el.value
      else
        convert_children(el.children).join
      end

      inline_format(element, style)
    end

    # Returns the layout configuration for a specific element type
    #
    # @param element [Symbol] element type
    # @param selector [Object] sub selector for type
    #   (e.g. 1 for heading level 1)
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

    def style_for_paragraph(i)
      style = style_for(:default)
      paragraph = layout_for(:paragraph)
      style.merge!(paragraph.to_h) if paragraph.indent?(i)
      style
    end

    def reset_paragraph_count!
      @paragraph_count = 0
    end
  end
end
