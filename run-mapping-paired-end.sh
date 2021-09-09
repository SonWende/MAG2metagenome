#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80


files="paired/end/files.txt"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $files)

basedir=
r1=$basedir/reads/${sample}_1.fastq
r2=$basedir/reads/${sample}_2.fastq

# run mapping
bbmap.sh build=1 in=$r1 in2=$r2 idfilter=0.97 outm=$basedir/${sample}.mapped.sam statsfile=$basedir/${sample}.statsout threads=80 

# convert to bam
samtools view -bS $basedir/${sample}.mapped.sam > $basedir/${sample}.mapped.bam
# run intersect 
bedtools intersect -a $basedir/${sample}.mapped.bam -b /beegfs/wende/Steigerwald/bin2/test_mapping_validity/blast_refseq/blast_to_refseq_positions.bed -v > $basedir/${sample}.filtered.bam	

