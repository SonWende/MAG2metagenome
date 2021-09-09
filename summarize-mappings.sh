#!/bin/bash
cat sra-ids.txt | while read line;do echo $line; grep "Reads Used:" $line.statsout | cut -f2 ;grep "unambiguous:  " $line.statsout | cut -f2,3 ; done | awk 'NR%4{printf "%s\t", $0;next;}1' > mapped.stats.unfiltered.tsv
sed  -i '1i Sample\tReads\tfwd percent mapped(unambiguous)\tfwd reads mapped(unambiguous)\trvs percent mapped(unambiguous)\trvs reads mapped(unambiguous)' mapped.stats.unfiltered.tsv
for f in *.filtered.bam ; do echo $f ; samtools flagstat $f | grep "mapped (" ; done | awk 'NR%2{printf "%s\t", $0;next;}1' > mapped.stats.filtered.tsv
