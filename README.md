# galaxy_make_otu_table_example

The purpose of this tool is to group reads in OTUs and count the number
of reads within each OTU. Most of the time this will be amplicon data that
has been sequenced on an NGS platform (Illumina, IonTorrent, etc.)
Before the **"Make otu table"** tool can be used reads should at least be merged
(assuming paired-end data) and preferably trimmed.  

\*.fastq.gz pairs need to be in the format "*filename*.**R1**.fastq.gz" and "*filename*.**R2**.gz"  

**"Merge reads"** will only accept zip files. Use **"Manage ZIP"** to zip the fastq.gz pairs.
