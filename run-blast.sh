#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80
blastdb=/path/to/refseq/blast/database
query=/path/to/bin
blastn -query $query \
		-db $blastdb \
		-num_threads 80 \
		-outfmt "6 qseqid sseqid qaccver pident qcovhsp length mismatch gaps qstart qend sstart send frames evalue bitscore qseq sseq" \
		-out pident97.blastout \
		-max_target_seqs 500 \
		-perc_identity 97

cat pident97.blastout | awk '{print($1"\t"$9-1"\t"$10)}' > positions_to_ignore.bed