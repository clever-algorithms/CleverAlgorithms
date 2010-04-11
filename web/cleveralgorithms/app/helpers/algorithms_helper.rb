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
  
  # make a table  
  def make_bibliography(content)
    paragraphs = content.split("\n")
    new_content = ""
    new_content << "<table class='algorithm_bibliography_table'>"
    paragraphs.each do |p|
      index = p.index(':')
      link, ref = p[0...index], p[index+1..p.length]      
      new_content << "<tr class='algorithm_bibliography_tr'>"
      new_content << "<td><a name='#{link}'></a>[#{link}]</td>"
      new_content << "<td>#{process_reference_link_name(ref)}</td>"
      new_content << "</tr>"
    end
     new_content << "</table>"
    return new_content
  end
  
  def process_reference_link_name(ref)
    split = ref.strip.split('.')
    content = ""
    split.each_with_index do |p, i|
      next if p.empty? or p.strip.empty?
      content << "#{p}." and next if i != split.length-2
      name = p.strip
      content << " <a href='http://scholar.google.com/scholar?q=#{name}'>#{name}</a>."
    end  
    return content
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
  
  def unreleased_text
    "<span class='coming_soon'>Coming Soon.</span>"
  end
  
  def algorithm_color(algorithm)
    return "\#FFF" if algorithm.nil? or algorithm.kingdom.blank?
    kingdom = algorithm.kingdom.downcase
    # bright green
    return "\#EFFBEF" if kingdom == "evolutionary"
    # red
    return "\#FBEFEF" if kingdom == "swarm"
    # light blue
    return "\#EFF5FB" if kingdom == "stochastic"
    # orange
    return "\#FBF5EF" if kingdom == "physical"
    # light pink
    return "\#FBEFFB" if kingdom == "probabilistic"
    # purple
    return "\#F5EFFB" if kingdom == "immune"
    
    
    return "\#FFFFFF"
  end
  
end
