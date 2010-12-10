
# IQR calculations for boxplots
# http://stackoverflow.com/questions/1744525/ruby-percentile-calculations-to-match-excel-formulas-need-refactor
def get_quartile(array, quartile)
  # Returns nil if array is empty and covers the case of array.length == 1
  return array.first if array.length <= 1
  sorted = array.sort
  # The 4th quartile is always the last element in the sorted list.
  return sorted.last if quartile == 4
  # Source: http://mathworld.wolfram.com/Quartile.html
  quartile_position = 0.25 * (quartile*sorted.length + 4 - quartile)
  quartile_int = quartile_position.to_i
  lower = sorted[quartile_int - 1]
  upper = sorted[quartile_int]
  lower + (upper - lower) * (quartile_position - quartile_int)
end

def load_file(filename)
  data = []
  lines = IO.readlines(filename)
  lines.each {|line| data << line.strip.to_f}
  return data
end

def get_output_line(name, d)
  min = d.sort.first
  q1 = get_quartile(d, 1)
  q2 = get_quartile(d, 2)
  q3 = get_quartile(d, 3)
  max = d.sort.last
  "#{min} #{q1} #{q2} #{q3} #{max}\n"
end

if __FILE__ == $0
  r1 = load_file("ga_rs1.txt")
  r2 = load_file("ga_rs2.txt")
  r3 = load_file("ga_rs3.txt")
  data = ""
  data << get_output_line("1/300", r1)
  data << get_output_line("10/300", r2)
  data << get_output_line("100/300", r3)

  File.open("boxplots1.txt", "w") {|f| f.write(data)} 
  puts "wrote boxplots1.txt"
end
