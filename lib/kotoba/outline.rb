module Kotoba
  module Outline
    attr_reader :last_heading
    attr_accessor :headings

    # Register a heading for the outline of a document.
    # Finds the parent of the heading if any is available.
    # Headings should be registered in top down order.
    #
    # @param heading [Hash] hash of the heading
    #
    #     { name: "Chapter 1", level: 1, page: 1 }
    #
    def register_heading(heading)
      @headings ||= []
      heading[:children] ||= []
      parent = find_parent_heading_for_level(@last_heading, heading[:level])
      if parent
        # Heading is sub heading
        heading[:parent] = parent
        parent[:children] << heading
      else
        # Heading is root level heading
        @headings << heading
      end
      @last_heading = heading
    end

    protected

    # Finds the parent heading for the given level.
    # Will move up the tree to find the parent of the heading level.
    # If no parent is found the heading is root.
    #
    # @return [Hash, nil] the found parent (if any)
    #
    def find_parent_heading_for_level(heading, level)
      return if heading.nil?
      level_up = level - 1
      if heading[:level] == level_up
        heading
      else
        find_parent_heading_for_level(heading[:parent], level)
      end
    end
  end
end
