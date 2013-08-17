module Kotoba::Export
  class Document < Prawn::Document
    include Kotoba::Outline

    def initialize(options={}, &block)
      super(next_page_options.merge(Kotoba.config.to_h).merge(options), &block)
    end

    # Starts a new page in the Prawn document
    #
    # @see Prawn::Document's start_new_page method
    #
    def start_new_page(options={})
      super(next_page_options.merge(options))
    end

    # Returns a hash with options for the next page creation.
    # The values depend on the defined layout for the to be created page.
    #
    # @return [Hash] hash with page options
    #
    def next_page_options
      page_layout = layout_for(next_page_number)
      page_layout.to_h(next_page_number)
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

    # Returns the next page number.
    #
    # @return [Integer] next page number
    #
    def next_page_number
      page_is_first_page? ? 1 : (page_number + 1)
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
    # @return [Kotoba::Layout] the layout specified for the next page.
    #
    def layout
      layout_for(current_page_number)
    end

    # Returns the layout for the requested page.
    #
    # @param page_number [Integer] page number for the requested layout.
    #
    # @return [Kotoba::Layout] the layout for the specified page.
    #
    def layout_for(page_number)
      Kotoba.config.layout_for_page(page_number)
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
