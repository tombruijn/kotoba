# Kotoba

Book manager for Markdown files in Ruby.
Exports to PDF using the Ruby Prawn library.

_Currently Kotoba is in development.
It is not stable at all or feature ready yet.
See the GitHub issue tracker for the current status of features and plans.  
Use the this quick
[overview issue](https://github.com/tombruijn/kotoba/issues/1)
during initial development._

## Installation

First install the gem: `gem install kotoba`

Then create a new Kotoba project: `kotoba new <my book>`

## Usage

Kotoba is controlled from the command line.
`kotoba help` gives a quick overview of the available commands.

### Create a project `kotoba new <my book>`

To create your first project run the `kotoba new <my book>` command.

It creates a `config.rb` file (see config below), a Gemfile and a `book`
directory.
In the book directory you will find a `chapters` directory.
This is where Kotoba will look for files in alphabetical order and combine
them on export.

### Writing your book

Write your book in Markdown files. It's easy enough

TODO: Explain how Markdown metadata works and how this can be useful in
combination with the server.

### Exporting `kotoba export`

The goal of Kotoba is to provide an easy way to export Markdown files to PDF.
With the `kotoba export` command you will export your book to PDF
(or plain text).

An export will create a `build` directory in your project's root if none exists.
It will place the export result into this directory when it is done.

## Requirements

1. Ruby >= 1.9

## Supported exports

- PDF (through Prawn)
- Plain text

## Future features

- Manage markdown files in an easy way.
- Use your own editor!
- Export to PDF (and plain text).
- Generate a Table of Contents.
- Customize the layout and styling of your book.
- Add your own fonts to the PDF export.
- Kotoba server  
  The server will allow for more easy browsing through your book using the
  metadata you can add to the markdown files.
  - A simple overview of all chapters.
    Shows a short summary/full summary or keywords, multiple views will be
    supported.
  - Page-_like_ preview.  
    Actual pages with page breaks, like LibreOffice/OpenOffice Writer or
    Microsoft Office Word, will probably not be supported in this preview mode.
  - Keywords link to a keyword page which lists all chapters where they occur.
  - Simple statistics:
    - See word, line and chapter count.

## Config

TODO: List all options with default values and explain how default settings
work.

`config.rb`

```ruby
require "kotoba"

Kotoba.config do |config|
  # Declare the title of your book
  # This will be set in the PDF
  config.title = "Preview book"
  # List the authors of the book
  config.authors = ["Tom de Bruijn"]
  # Declare the filename you wish to have it export to
  config.filename = "preview-book"

  # Declare which exports to use
  config.export_to :pdf
  config.export_to :text

  # Define the default style (optional)
  config.layout do |l|
    # Page size, uses Prawn's known formats
    l.size = "LETTER"
    # Or use the more customizable settings with and height
    # Page width and height
    l.width = 15.cm
    l.height = 23.cm
    # Page margins (text distance from page edges)
    l.margin do |m|
      m.top = 1.5.cm
      m.bottom = 1.6.cm
      m.inner = 2.cm
      m.outer = 1.7.cm
    end

    # Default styling for any text in the PDF
    l.default do |d|
      d.font = "Times-Bold"
      d.color = "FF0000"
      d.size = 11.5.pt
      d.line_height = 13.pt
      d.style = [:bold] # bold, italic
    end
    
    # Styling for paragraphs
    # A paragraph is everything not a different element
    l.paragraph do |p|
      p.indent = false
    end

    # Define styling for headings
    # heading count can go as high as markdown supports
    l.heading 1 do |h|
      h.size = 30.pt
    end
    l.heading 2 do |h|
      h.size = 20.pt
    end

    # Define headers and footers
    # Headers and footers are recurring elements that will be placed on
    # every page
    l.header do |h|
      # Automatic page numbering
      h.page_numbering do |n|
        n.active = true # true/false, default: false
        n.align = :right # left, center, right
      end
      # Add additional content to the header
      # Will give the prawn object that can be used to write text, etc.
      h.content do |prawn|
        prawn.text "I'm a header", :align => :left
      end
    end

    # Define footers
    l.footer do |f|
      f.color = "FF0000"
      f.page_numbering do |n|
        n.active = true
        n.align = :right
      end

      f.content do |prawn|
        prawn.text "Hello footer!", :align => :left
      end
    end
  end

  # Special layout for the first page
  config.layout_for 1 do |l|
    l.paragraph do |p|
      p.indent = true
    end
  end
end
```

## License

Kotoba released under the MIT License. See the bundled LICENSE file for details.
