module AlgorithmsHelper
  
  def make_paragraphs(content)
    paragraphs = content.split("\n")
    new_content = ""
    paragraphs.each do |paragraph|
      new_content << "<p>#{prepare_paragraph(paragraph)}</p>"
    end
    return new_content
  end
  
  def make_unorded_list(content)
    paragraphs = content.split("\n")
    new_content = ""
    new_content << "<ul>"
    paragraphs.each do |paragraph|
      new_content << "<li>#{prepare_paragraph(paragraph)}</li>"
    end
     new_content << "</ul>"
    return new_content
  end
  
  def prepare_paragraph(paragraph)    
    parts = paragraph.split('\cite{')
    return paragraph if parts.size == 1
    rs = ""
    parts.each_with_index do |s, i|
      rs << s and next if i == 0
      first = s.index('}')      
      ref = s[0...first]
      rs<<"(<a href='##{ref}'>#{ref}</a>)"
      rs << s[first+1..s.length]
    end
    
    return rs
  end
  
end
