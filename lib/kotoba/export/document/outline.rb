class Kotoba::Export::Document
  # Adds an outline to the prawn document.
  # Makes navigation of the document easier.
  #
  def outline!
    outline_chapter_headings(@headings)
  end

  protected

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
