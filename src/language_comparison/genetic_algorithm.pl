# Genetic Algorithm in the Perl Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

use constant NUM_GENERATIONS => 100;
use constant NUM_BOUTS => 3;
use constant POP_SIZE => 100;
use constant NUM_BITS => 64;
use constant P_CROSSOVER => 0.98;
use constant P_MUTATION => (1.0/NUM_BITS);
use constant HALF => 0.5;

sub onemax {
	$sum = 0;
	while ($_[0]=~ /(.)/g) {
		if($1 == '1') {
			$sum = $sum + 1;
		}		
	}
  	return $sum;
}

sub mutation {
	$string = "";
	while ($_[0]=~ /(.)/gs) {
		if(rand() < P_MUTATION) {
			if($1=='1') {
				$string = $string . "0"
			}else{
				$string = $string . "1"
			}
		} else { 
      		$string = $string . $1;
		}
  }
  return $string;
}

# print(onemax("001111100")."\n");
print(mutation("11111111")."\n");