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
	my $bitstring = $_[0];
	my $sum = 0;
	$sum += $1 while $bitstring =~ s/^(.)//;
  	return $sum;
}

sub mutation {
	my $bitstring = $_[0];
	$bitstring =~ s/(.)/rand() < P_MUTATION ? $1^1 : $1/ge;
	return $bitstring;
}

sub crossover {
	my ($parent1, $parent2) = ($_[0], $_[1]);
	if(rand() < P_CROSSOVER) {
		my $cut = int(rand(NUM_BITS-2)) + 1;
		return (substr($parent1, 0, $cut).substr($parent2, $cut), substr($parent2, 0, $cut).substr($parent1, $cut));
	}
	return ("".$parent1, "".$parent2);
}

sub random_bitstring {
	my $string = "-" x NUM_BITS;
	$string =~ s/(.)/rand() < HALF ? 0 : 1/ge;
	return $string;
}

sub tournament {
	my @population = @{$_[0]};
  	my $best = '';
	for my $p (0..(NUM_BOUTS-1)) {	
		$i = int(rand(@population));		
		if($best eq '' or $population[$i]{fitness} > ${$best}{fitness}){
			$best = $population[$i];
		}
	}
	return $best;
}

sub evolve {
	my @population;
	for my $p (0..(POP_SIZE-1)) {	
		push @population, {bitstring=>random_bitstring(), fitness=>0};
	}	
	for $candidate (@population) {
		$candidate->{fitness} = onemax($candidate->{bitstring});
	}	
	my @sorted = sort{$b->{fitness} <=> $a->{fitness}} @population;
	my $gen = 0;
	my $best = $sorted[0];
	while(${$best}{fitness}<NUM_BITS and $gen<NUM_GENERATIONS) {
		my @children;
		while(@children < POP_SIZE) {
			$p1 = tournament(\@population);
			$p2 = tournament(\@population);
			my ($c1, $c2) = crossover(${$p1}{bitstring}, ${$p2}{bitstring});
			push @children, {bitstring=>mutation($c1), fitness=>0};
			if(@children < POP_SIZE) {
				push @children, {bitstring=>mutation($c2), fitness=>0};
			}
		}
		for $candidate (@children) {
			$candidate->{fitness} = onemax($candidate->{bitstring});
		}
		@sorted = sort{$b->{fitness} <=> $a->{fitness}} @children;
		if($sorted[0]{fitness}>${$best}{fitness}) {
			$best = $sorted[0];
		}
		@population = @children;		
		$gen = $gen + 1;
		print " > gen $gen, best: ${$best}{fitness}, ${$best}{bitstring}\n";
	}

	return $best;
}

$best = evolve();
print "done! Solution: best: ${$best}{fitness}, ${$best}{bitstring}\n";