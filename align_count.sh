#!/usr/bin/bash
#SBATCH -p short -N 1 -n 8 --mem 8gb

module load bwa
module load samtools
CPU=16
GENOME=REF_gDNA.fasta

if [ ! -d fastq ]; then
    mkdir -p ~/bigdata/----/fastq
    mkdir -p ~/bigdata/----/sam 
    mkdir -p ~/bigdata/----/bam 

    ln -s ~/bigdata/----/fasta .
    ln -s ~/bigdata/----/fastq .
    ln -s ~/bigdata/----/sam .
    ln -s ~/bigdata/----/bam .

    for fasta_file in $(ls -H fasta)
    do
        acc=$(basename "$fasta_file" .fasta)
        SINGLE_READ=fastq/${acc}.fastq

        echo "Converting $fasta_file to mock $SINGLE_READ";
        seqtk seq -F 'I' "fasta/$fasta_file" > "$SINGLE_READ"

        bwa index $GENOME
        bwa mem -t $CPU $GENOME $SINGLE_READ -o sam/${acc}.sam
        samtools fixmate -O bam sam/${acc}.sam bam/${acc}_fixmate.bam
        samtools sort --threads $CPU -O BAM -o bam/${acc}.bam bam/${acc}_fixmate.bam
        samtools index bam/${acc}.bam
    done
fi

echo -e ">samtools flagstat bam/${acc}.bam -O tsv"
echo ">${acc}" > "flagstats.tsv"
samtools flagstat "bam/${acc}.bam" -O tsv >> "flagstats.tsv"

mkdir -p ~/bigdata/dynamic_genome_020_024/sunyans/fixmate_bam
mkdir -p ~/bigdata/dynamic_genome_020_024/sunyans/bai_bam
ln -s ~/bigdata/dynamic_genome_020_024/sunyans/fixmate_bam .
ln -s ~/bigdata/dynamic_genome_020_024/sunyans/bai_bam .
mv ~/bigdata/dynamic_genome_020_024/sunyans/bam/*fixmate* fixmate_bam
mv ~/bigdata/dynamic_genome_020_024/sunyans/bam/*bai* bai_bam
