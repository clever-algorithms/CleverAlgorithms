# Utilities

module Utils
  
  # Helper class for managing peudorandom numbers, wraps Kernel::srand. 
  class RandomNumberGenerator
    attr_reader :seed
    
    def initialize(seed=0)
      start_sequence(seed)
    end
    
    # seed the random number generator
    def start_sequence(seed)
      @seed = seed
      Kernel::srand(@seed)
    end
  
    # x in [0,1)
    def next_float
      Kernel::rand
    end
  
    # x in [0, max)
    def next_int(max)
      Kernel::rand(max)
    end
  
    # x in {true, false}
    def next_bool
      Kernel::rand < 0.5
    end
  
    # x in [min, max)
    def next_bfloat(min, max)
      min + ((max - min) * Kernel::rand)
    end
  
    # x with a mean of 0.0 and a standard deviation of 1.0
    def next_gaussian
      u1 = u2 = w = g1 = g2 = 0  # declare
      begin
        u1 = 2 * Kernel::rand - 1
        u2 = 2 * Kernel::rand - 1
        w = u1 * u1 + u2 * u2
      end while w >= 1

      w = Math::sqrt( ( -2 * Math::log(w)) / w )
      g2 = u1 * w;
      g1 = u2 * w;
      return g1
    end
  
    # x with a defined mean and standard deviation
    def next_bgaussian(mean, stdev)
      mean + stdev * next_gaussian
    end
        
  end
  
  
  # Helpers for common number constants and functions
  module Numbers
    # zero: x.zero? => true
    ZERO = 0.0
  
    # infinity: x.infinite => true
    INF = 1.0/0.0
    POS_INF = +INF
    NEG_INF = -INF
  
    # not a number: x.nan? => true
    NAN = 0.0/0.0
  end
  
  
  module CollectionUtils 
    
    # The Fisher-Yates shuffle: http://en.wikipedia.org/wiki/Knuth_shuffle
    def self.shuffle(array)
      n = array.length
      for i in 0...n
        r = rand(n-i) + i
        array[r], array[i] = array[i], array[r]
      end
      return array
    end
    
  end
  
  
  
  
  def self.demo_random_number_generator()
    rand = RandomNumberGenerator.new(66)
    puts "Seed is: #{rand.seed}"
    puts "A float: #{rand.next_float}"
    puts "An int between 0 and 100: #{rand.next_int(100)}"
    puts "A boolean: #{rand.next_bool}"
    puts "A float between -1.0 and 1.0: #{rand.next_bfloat(-1.0, 1.0)}"
    puts "A Gaussian float: #{rand.next_gaussian}"
    puts "A Gaussian, mean of 50 stdev of 10: #{rand.next_bgaussian(50, 10)}"
  end
  
  def self.demo_numbers()
    puts "Zero: #{Numbers::ZERO}"
    puts "Infinity: #{Numbers::INF}"
    puts "Positive Infinity: #{Numbers::POS_INF}"
    puts "Negative Infinity: #{Numbers::NEG_INF}"
    puts "Not a Number: #{Numbers::NAN}"
  end
  
  def self.demo_collection_utils
    ordered_array = Array.new(10){|i|i}    
    puts "Shuffled array: #{CollectionUtils.shuffle(ordered_array.clone)}"
  end
  
end



# Utils::demo_random_number_generator; puts
# Utils::demo_numbers; puts
# Utils::demo_collection_utils; puts
