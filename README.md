# MAG2metagenome
Scripts to screen metagenomics short read datasets for the presence of a genome, MAG or bin of interest.

Pipeline consists of 3 steps:
1) Identification of potential ambiguous mapping sites in MAG (or genome)
3) Mapping metagenomics short reads to MAG at 97% identity with B
4) Remove ambiguous mappings


### 1. Identification of potential ambiguous mapping sites in MAG
Blast MAG against refseq (or nt) database:
<pre><code>blastn -query $bin \
        -db $ntblastdb \
        -num_threads 80 \
        -outfmt "6 qseqid sseqid qaccver pident qcovhsp length mismatch gaps qstart qend sstart send frames evalue bitscore qseq sseq" \
        -out pident97.blastout \
        -max_target_seqs 500 \
        -evalue 0.001 \
        -perc_identity 97</code></pre>

Produce a bed file from blast tabular output:
<pre><code>cat pident97.blastout | awk '{print($1"\t"$9-1"\t"$10)}' > positions_to_ignore.bed</code></pre>

### 2. Mapping metagenomics short reads with BBmap.sh
Build mapping index for MAG
<pre><code>bbmap.sh ref=$bin</code></pre>

Run bbmap.sh on  metagenomes (single-end or paired-end)
<pre><code>for sample in metagenomes; do 
  # single end
  # bbmap.sh build=1 in=$r1 idfilter=0.97 outm=$outdir/${sample}.mapped.sam statsfile=$outdir/${sample}.statsout threads=80
  # paired end
  bbmap.sh build=1 in=$r1 in2=$r2 idfilter=0.97 outm=$outdir/${sample}.mapped.sam statsfile=$outdir/${sample}.statsout
done </code></pre>

### 3. Remove ambiguous mappings

Filter out mapped reads, that are mapped to regiosn in the MAg, that also produce high identiy alignemts to sequences in th refseq (or nt ) database.
<pre><code>for sample in metagenomes; do 
  # convert mapping results to bam and sort
  samtools sort $outdir/${sample}.mapped.sam > $outdir/${sample}.mapped.bam
  # run bedtools intersect to remove mappings that fall in ambiguous regions
  bedtools intersect -a $outdir/${sample}.mapped.bam -b positions_to_ignore.bed -v > $outdir/${sample}.filtered.bam	
</code></pre>

### 4. Collect mapping information
Collect the number of mapped reads for filtered and unfiltered mappings to tsv files
<pre><code># grep number of mapped reads from stats file (for paired end data)for sample in *.statsout;do 
  echo $sample; 
  grep "Reads Used:" $sample.statsout | cut -f2 ;grep "unambiguous:  " $sample.statsout | cut -f2,3 
done | awk 'NR%4{printf "%s\t", $0;next;}1' > mapped.stats.unfiltered.tsv
# add column headers
sed  -i '1i Sample\tReads\tfwd percent mapped(unambiguous)\tfwd reads mapped(unambiguous)\trvs percent mapped(unambiguous)\trvs reads mapped(unambiguous)' mapped.stats.unfiltered.tsv
# grep number of reads after filtering
for f in *.filtered.bam ; do 
  echo $f ; 
  samtools flagstat $f | grep "mapped (" 
done | awk 'NR%2{printf "%s\t", $0;next;}' > mapped.stats.filtered.tsv
</code></pre>
