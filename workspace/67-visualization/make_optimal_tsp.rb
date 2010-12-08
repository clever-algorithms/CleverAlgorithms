# prepare berlin52 optimal tour data for plot

def get_city_hash(filename)
  cities = IO.readlines(filename)
  hash = {}
  cities.each do |city|
    parts = city.split(" ")
    record = {}
    record[:x],record[:y] = parts[1], parts[2]
    hash[parts[0]] = record
  end
  return hash
end

def load_tour(filename)
  cities = IO.readlines(filename)
  permutation = []
  cities.each do |city|
    permutation << city.strip
  end
  return permutation
end

def create_optimal_tour_coords(hash, permutation, filename)
  s = ""
  permutation.each do |city|
    coords = hash[city]
    s << "#{coords[:x]} #{coords[:y]}\n"
  end
  coords = hash[permutation.first]
  s << "#{coords[:x]} #{coords[:y]}\n"
  File.open(filename, "w") { |f| f.printf(s) }
  puts "Wrote #{filename}"
end

if __FILE__ == $0
  hash = get_city_hash("berlin52.tsp.orig")
  puts "loaded #{hash.length} citites"
  permutation = load_tour("berlin52.opt.tour")
  puts "loaded optimal permitation with #{permutation.length} citites"
  create_optimal_tour_coords(hash, permutation, "berlin52.optimal")
end
