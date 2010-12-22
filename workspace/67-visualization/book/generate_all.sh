#!/bin/sh

# basin1
gnuplot <<END
set terminal latex
set output "basin1.tex"
set size 4/5., 3/3.
unset key
set xrange [-5:5]
plot x*x
END

# basin2
gnuplot <<END
set terminal latex
set output "basin2.tex"
set size 4/5., 3/3.
unset key
set xrange [-5:5]
set yrange [-5:5]
set zrange [0:50]
splot x*x+y*y
END

# tsp1
gnuplot <<END
set terminal latex
set output "tsp1.tex"
set size 4/5., 3/3.
unset key
plot "berlin52.tsp"
END

# ga1
gnuplot <<END
set terminal latex
set output "ga1.tex"
set size 4/5., 3/3.
unset key
set yrange [45:64]
plot "ga1.txt" with linespoints
END

# ga2
gnuplot <<END
set terminal latex
set output "ga2.tex"
set size 4/5., 3/3.
unset key
set yrange [0:17]
set xrange [275:290]
plot "ga2.histogram.txt" with boxes
END

# ga3
gnuplot <<END
set terminal latex
set output "ga3.tex"
set size 4/5., 3/3.
unset key
set bars 15.0
set xrange [-1:3]
plot 'boxplots1.txt' using 0:2:1:5:4 with candlesticks whiskerbars 0.5
END

# pso1
gnuplot <<END
set terminal postscript
set output "pso1.ps"
set size square
unset key
set xrange [-5:5]
set yrange [-5:5]
set pm3d map
set palette gray negative
set samples 20
set isosamples 20
splot x*x+y*y, "pso1.txt" using 1:2:(0) with points
END

ps2pdf pso1.ps pso1.pdf

# tsp3
gnuplot <<END
set terminal latex
set output "tsp3.tex"
set size 4/5., 3/3.
unset key
plot "berlin52.nn.tour" with linespoints
END

# tsp2
gnuplot <<END
set terminal latex
set output "tsp2.tex"
set size 4/5., 3/3.
unset key
plot "berlin52.optimal" with linespoints
END
