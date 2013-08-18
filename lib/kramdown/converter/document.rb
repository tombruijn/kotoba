class Kramdown::Document
  def to_prawn(prawn)
    Kramdown::Converter::Prawn.convert(@root, @options, prawn)
  end
end
