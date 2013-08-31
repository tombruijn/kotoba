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

Write your book in Markdown files. It's easy enough to start since you
can use your own editor. Create a new file in the `book/chapters` directory
to get started. Alternatively, if you like more management of your files,
create subdirectories for each chapter and place your files in each directory.

Example:

```
book/
- chapters/
  - 01_intro/
    - 01_intro.md
    - 02_prelude.md
  - 02_hello/
    - 01_hello-world.md
```

Note: Kotoba uses a alphabetic sorting, which pretty closely resembles most
operating systems' sorting. Numbers and symbols are sorted before letters.
Other than for sorting purposes it does not matter what your files are called.

__TODO___: Explain how Markdown metadata works and how this can be useful in
combination with the server.

### Exporting `kotoba export`

The goal of Kotoba is to provide an easy way to export Markdown files to PDF.
With the `kotoba export` command you will export your book to PDF.

An export will create a `build` directory in your project's root if none exists.
It will place the export result into this directory when it is done.

## Requirements

1. Ruby >= 1.9

## Supported exports

- PDF (through Prawn)

## Future features

- Manage markdown files in an easy way.
- Use your own editor!
- Export to PDF.
- Generate a Table of Contents.
- Customize the layout and styling of your book.
- Add your own fonts to the PDF export.
- Kotoba server (might be moved into its own gem)  
  The server will allow for more easy browsing through your book using the
  metadata you can add to the markdown files.
  - A simple overview of all chapters.
    Shows a short summary/full summary or keywords, multiple views will be
    supported.
  - Page - _like_ preview.  
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
  # Set the title of your book
  config.title = "Preview book"
  # Subject
  config.subject = "Subject of preview book"
  # List the authors of the book
  config.authors = ["Tom de Bruijn"]
  # Keywords
  config.keywords = "preview book prawn pdf kotoba"
  # Creator
  config.creator = "Creator of this book"
  # Producer
  config.producer = "Kotoba using Prawn"
  # Custom metadata
  config.metadata = {
    :Foo => "Bar"
  }

  # Declare the filename you wish to have it export to
  config.filename = "preview-book"

  # Declare which exports to use
  config.export_to :pdf

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

## Code status

[![Code Climate](https://codeclimate.com/github/tombruijn/kotoba.png)](https://codeclimate.com/github/tombruijn/kotoba)

## License

Kotoba released under the MIT License. See the bundled LICENSE file for details.
