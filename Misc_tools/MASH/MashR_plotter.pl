#!/usr/bin/perl
# Pombert lab 2016
# Plot Mash distances from CSV files generated by MashToDistanceCSV.pl
# Requires R, R-devel
# Optional: To install the igraph package in R: type install.packages("igraph")

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

## Defining options
my $usage = 'USAGE = MashR_plotter.pl [OPTIONS]

OPTIONS:
--input (-i)		Input file [Default: Mash.mashdist.csv]
--output (-o)		Output R script [Default: Mash.R]
--pdf			Output PDF plot [Default: plot.pdf]
--plotter (-p)		R plotter (plot, igraph) [Default: plot]
--fonts			Fonts [Default: Times]
--xrange (-x)		Plot width [Default: 0.005]
';

die "$usage\n" unless @ARGV;

my $input = 'Mash.mashdist.csv';
my $output = 'Mash.R';
my $pdf = "plot.pdf";
my $plotter = 'plot';
my $fonts = "Times";
my $xrange = '0.005';

GetOptions(
	'input|i=s' => \$input,
	'output|0=s' => \$output,
	'pdf=s' => \$pdf,
	'plotter|p=s' => \$plotter,
	'fonts=s' => \$fonts,
	'xrange|x=s' => \$xrange,
);

open IN, "<$input" or die "Cannot open $input\n";
open OUT, ">$output";

## Generating R script commands
print OUT '#!/usr/bin/Rscript'."\n";
print OUT 'mash <- read.csv("'."$input".'", sep=",")'."\n";
print OUT 'row.names(mash) <- mash[, 1]'."\n";
print OUT 'mash <- mash[, -1]'."\n";
print OUT 'fit <- cmdscale(mash, eig = TRUE, k = 2)'."\n"; ## Run Multidimensional Scaling (MDS) with function cmdscale(), and get x and y coordinates.
print OUT 'x <- fit$points[, 1]'."\n";
print OUT 'y <- fit$points[, 2]'."\n";

## Creating list of names
print OUT 'strain.name <- c(';
while (my $line = <IN>){
	chomp $line;
	$line =~ s/.fasta//g;
	if ($line =~ /(^,(.*)$)/){
		my @names = split(',', $line);
		my $rotation = scalar@names - 2;
		my $end = scalar@names - 1;
		for my $name (1..$rotation){
			print OUT "\"$names[$name]\"\,";
		}
		print OUT "\"$names[$end]\""."\)\n";
	}
}

## Generating R PDF output command
print OUT 'pdf(file="'."$pdf".'", useDingbats=FALSE, family="'."$fonts".'", pointsize=16, width=16,height=10)'."\n";

## Choosing plotter
if ($plotter eq 'plot'){
	print OUT 'plot(x, y, pch = 1, xlim = range(x) + c(0, '."$xrange".'))'."\n";
	print OUT 'text(x, y, pos = 4, labels = strain.name)'."\n";
}
elsif ($plotter eq 'igraph'){
	print OUT 'library(igraph)'."\n";
	print OUT 'g <- graph.full(nrow(mash))'."\n";
	print OUT 'V(g)$label <- strain.name'."\n";
	print OUT 'layout <- layout.mds(g, dist = as.matrix(mash))'."\n";
	print OUT 'plot(g, layout = layout, vertex.size = 1)'."\n";
}
close IN;
close OUT;

## Running R script
system "chmod a+x $output\; ./$output";