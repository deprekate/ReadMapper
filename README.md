# ReadMapper
ReadMapper is a program that maps sequencing reads to a nucleotide backbone, and then creates a publication quality figure.

## Quick start ##
```sh
Rscript ReadMapper.R READ_MAPPINGS.BLASTN [ORF_MAPPINGS.BLASTN]
```

## Testing ##
To test whether your ReadMapper install is working correctly, you can run the command:
```
Rscript ReadMapper.R -test
```


## Prepare input data ##        
You will need to create alignment coordinates between the reads and nucleotide backbone.
The input files that the form of two<sup>†</sup> tab seperate columns: the start and end of the read alignment.
    † ReadMapper currently requires the very first line to contain the backbone length in a third column.

The easiest way to do this is to use BLASTN with the command below:
```
     blastn -subject GENOME.FNA -query READS.FNA -outfmt '6 sstart send slen' -max_target_seqs 1 > READ_MAPPINGS.BLASTN
```
If your sequencing reads file is large, an alterniative to BLASTN, would be optimized aligners, such as bowtie or bwa.

Converting your `GENOME.FNA` file to a BLASTN database will also speed up the read alignment step. This can be accomplished
by using the command:
```
     makeblastdb -in GENOME.FNA -dbtype nucl
```
and then running the command:
```
     blastn -db GENOME.FNA -query READS.FNA -outfmt '6 sstart send slen' -max_target_seqs 1 > READ_MAPPINGS.BLASTN
```

                
Optionally you can plot the ORFS on the figure, in their respective frames.
To create these mappings use the command below:
```
     blastn -subject GENOME.FNA -query ORFS.FNA -outfmt '6 sstart send slen' -max_target_seqs 1 > ORF_MAPPINGS.BLASTN
```

## Output ##
If ReadMapper ran correctly you should get an output image titled figure.tiff.  If you use the test data, the figure will
look like the image below:
![](https://github.com/deprekate/ReadMapper/blob/master/figure.png)

