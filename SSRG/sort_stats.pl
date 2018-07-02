#!/usr/bin/perl
## Pombert lab, 2017-2018
my $version= '0.1c';

use strict; use warnings; use Math::Complex; use Getopt::Long qw(GetOptions);

my $usage = "sort_stats.pl -s *.stats -o output_name\n"; my $hint = "\nType -h for help"; die "\nUSAGE = $usage$hint\n\n" unless @ARGV;

## Defining options
my $options = <<'END_OPTIONS';
OPTIONS:
-h (--help)	Display this list of options
-v (--version)	Display script version
-s (--stats)	Stats files obtained from get_SNPs.pl
-o (--output)	Desired table output name; extension will be appended
-f (--format)	Desired table format, tsv or csv [Default: tsv]

END_OPTIONS

my $help;
my $vn;
my @stats;
my $output;
my $format = 'tsv';
GetOptions(
	'h|help' => \$help,
	'v|version' => \$vn,
	's|stats=s@{1,}' => \@stats,
	'o|output=s' => \$output,
	'f|format=s' => \$format
);
if ($help){die "\nUSAGE = $usage\n$options";} if ($vn){die "\nversion $version\n\n";}

## Initializing table & creating headers for species/strains/isolates
open OUT, ">$output.$format";
my %species = (); my $type; my $sep;
if ($format eq 'tsv'){$sep = "\t";}
elsif ($format eq 'csv'){$sep = ",";}
print "NOTE - Species names are derived from the FASTQ files used for read mapping with get_SNPs.pl...\n";
foreach(@stats){
	if ($_ =~ /fastq.([a-zA-Z_0-9\-]+).*\.(\w+).stats$/){
		$type = $2;
		if (exists $species{$1}){next;}
		else {$species{$1} = $1; print OUT "${sep}${1}${sep}${sep}${sep}"; print "Found species: $1\n";}
	}
}
print OUT "\n";
my $num = scalar (keys %species); my $col;
if ($type eq 'both'){$col = "${sep}% cov${sep}total SNPs+Indels${sep}SNP+indel per KB${sep}";}
elsif ($type eq 'snp'){$col = "${sep}% cov${sep}total SNPs${sep}SNP per KB${sep}";}
elsif ($type eq 'indel'){$col = "${sep}% cov${sep}total indels${sep}indel per KB${sep}";}
my $head = ($col)x($num);
print OUT "$head\n";

## Iterating through/parsing stats files
my $species = undef;
my $minc = 100;
my $maxsnp = 0;
my $maxsnpkb = 0;
my $sumsnp = '0';
my $count = '0';
my $snkbsum = '0';
while (my $file = shift@stats){
	open IN, "<$file";
	my $sp = undef;
	my $depth = undef;
	my $snps = undef;
	my $snkb = undef;
	while (my $line = <IN>){
		chomp $line;
		if ($line =~ /^FASTQ file\(s\) used: ([a-zA-Z_0-9\-]+).*.fastq/){$sp = $1;}
		elsif ($line =~ /^Sequencing breadth \(percentage of bases covered by at least one read\)\s+(\S+)\%/){$depth = $1; if ($depth < $minc){$minc = $depth;}}
		elsif ($line =~ /^Total number of (SNPs|SNPs \+ indels|indels) found: (\d+)/){$snps = $2; $sumsnp += $2; $count++; if ($snps > $maxsnp){$maxsnp = $snps;}}
		elsif ($line =~ /^Average number of (SNPs|SNPs \+ indels|indels) per Kb: (\S+)/){$snkb = $2; $snkbsum+= $2; if ($snkb > $maxsnpkb){$maxsnpkb = $snkb;}}
	}
	if (defined $species){
		if ($species eq $sp){print OUT "${sep}${sep}${depth}${sep}${snps}${sep}${snkb}";}
		else{$species = $sp; print OUT "\n${species}${sep}${depth}${sep}${snps}${sep}${snkb}";}
	}
	else{$species = $sp;print OUT "${species}${sep}${depth}${sep}${snps}${sep}${snkb}";}
}
my $avsnp = sprintf ("%.2f", ($sumsnp/$count));
my $avsnb = sprintf ("%.2f", ($snkbsum/$count));
my $spp = sqrt($count);
print OUT "\n\n";
print OUT "Number of species found in node:${sep}$spp\n";
print OUT "Minimum genome coverage${sep}$minc \%\n";
print OUT "Max SNP total between species${sep}$maxsnp\n";
print OUT "Average SNP total between species${sep}$avsnp\n";
print OUT "Max SNP/kb total${sep}$maxsnpkb\n";
print OUT "Average SNP/kb between species${sep}$avsnb\n";
