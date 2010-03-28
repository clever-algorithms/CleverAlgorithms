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
      rs<<"[<a href='##{ref}'>#{ref}</a>]"
      rs << s[first+1..s.length]
    end
    
    return rs
  end
  
  def make_bibliography(content)
    paragraphs = content.split("\n")
    new_content = ""
    new_content << "<ul>"
    paragraphs.each do |p|
      index = p.index(':')
      link, ref = p[0...index], p[index+1..p.length]      
      new_content << "<li>"
      new_content << "<a name='#{link}'></a>"
      new_content << "[#{link}] : "
      new_content << ref
      new_content << "</li>"
    end
     new_content << "</ul>"
    return new_content
  end
  
  def make_links(content)
    paragraphs = content.split("\n")
    new_content = ""
    new_content << "<ul>"
    paragraphs.each do |p|
      index = p.index('$')
      text, link = p[0...index], p[index+1..p.length]
      new_content << "<li>"
      new_content << "<a href='#{link}'>#{text}</a>"
      new_content << "</li>"
    end
     new_content << "</ul>"
    return new_content
  end
  
end
