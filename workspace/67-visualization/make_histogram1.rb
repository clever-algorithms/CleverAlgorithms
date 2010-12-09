


if __FILE__ == $0
  lines = IO.readlines("ga2.txt")
  map = {}
  lines.each do |line|
    score = line.strip
    if map[score].nil?
      map[score] = 1
    else
      map[score] += 1
    end
  end
  
  sorted = map.keys.sort
  data = ""
  sorted.each {|key| data << "#{key} #{map[key]}\n"}
  File.open("ga2.histogram.txt", "w") {|f| f.write(data)}
  puts "done"
end