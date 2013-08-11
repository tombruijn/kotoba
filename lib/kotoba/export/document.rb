module Kotoba::Export
  class Document < Prawn::Document
    include Kotoba::Outline

    attr_accessor :sections

    def initialize(options={}, &block)
      @sections = []
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
      page_layout.to_h(current_page_count)
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

    # This method tells Prawn the outline of the document, a table of contents.
    # Will automatically nest chapters as long as the nesting is
    # done in advance and nested chapters are stored in the chapter's
    # children key as an array.
    #
    # @param list [Array] array with hashes that represent headings
    #
    # @see Kotoba::Outline's register_heading method for heading structure.
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

require "kotoba/export/document/layout"
require "kotoba/export/document/bounding_box"
require "kotoba/export/document/recurring_elements"
require "kotoba/export/document/content"
