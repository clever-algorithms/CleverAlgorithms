module AlgorithmsHelper
  
  def make_paragraphs(content)
    paragraphs = content.split("\n")
    new_content = ""
    paragraphs.each do |paragraph|
      new_content << "<p>#{h(paragraph)}</p>"
    end
    return new_content
  end
  
end
