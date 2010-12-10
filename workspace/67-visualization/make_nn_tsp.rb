
def euc_2d(c1, c2)
  Math.sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def calculate_neighbour_rank(city_number, cities, ignore=[])
  neighbors = []
  cities.each_with_index do |city, i|
    next if i==city_number or ignore.include?(i)
    neighbor = {:number=>i}
    neighbor[:distance] = euc_2d(cities[city_number], city)
    neighbors << neighbor
  end
  neighbors.sort!{|x,y| x[:distance] <=> y[:distance]}
  return neighbors
end

def nearest_neighbor_solution(cities)
  perm = [rand(cities.length)]
  while perm.length < cities.length
    neighbors = calculate_neighbour_rank(perm.last, cities, perm)
    perm << neighbors.first[:number]
  end  
  return perm
end

if __FILE__ == $0
  berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
   [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
   [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
   [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
   [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
   [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],
   [875,920],[700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],
   [595,360],[1340,725],[1740,245]]
  perm = nearest_neighbor_solution(berlin52)
  
  s = ""
  perm.each {|index| s << "#{berlin52[index][0]} #{berlin52[index][1]}\n"}
  s << "#{berlin52[perm.first][0]} #{berlin52[perm.first][1]}\n"
  File.open("berlin52.nn.tour", "w") {|f| f.write(s)}
  puts "wrote berlin52.nn.tour"
end
