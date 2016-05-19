#
#    ReadMapper
#
#    Copyright (C) 2016 Katelyn McNair
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

suppressMessages(library(methods))
suppressMessages(library(tools))
res <- try(library(ggplot2), silent = TRUE)
if(class(res) == "try-error"){
	stop("It appears you do not have the ggplot2 libarary installed. You can install it by running one of the following command under R: 
		>install.packages('ggplot2') ")
}

args<-commandArgs(TRUE)

file_reads = 'READ_MAPPINGS.BLASTN'
file_orfs = 'ORF_MAPPINGS.BLASTN'

if(is.na(args[1])==FALSE && args[1] == "-test"){
	cat("Testing...")
}else if(is.na(args[1]) || file.exists(args[1])==FALSE || (is.na(args[2])==FALSE && file.exists(args[2])==FALSE) ){
	stop("USAGE: %Rscript ReadMapper.R READ_MAPPINGS.BLASTN [ORF_MAPPINGS.BLASTN]
	
	You willl need to create the alignment coordinates between the reads and DNA backbone
	The easiest way to do this is to use blastn with the command below:
		blastn -subject GENOME.FNA -query READS.FNA -outfmt '6 sstart send slen' -max_target_seqs 1 > READ_MAPPINGS.BLASTN
		
	Optionally you can plot the ORFS on the figure, in their respective frames.
	To create these mappings use the command below:
		blastn -subject GENOME.FNA -query ORFS.FNA -outfmt '6 sstart send slen' -max_target_seqs 1 > ORF_MAPPINGS.BLASTN
	")
}else{
	file_reads = args[1]
	file_orfs = args[2]
}

first_line <- read.csv(file=file_reads,nrows=1, sep='\t',header=FALSE)
genome_length = unlist(first_line[3])
forward <- rep(0, genome_length)
reverse <- rep(0, genome_length)
orfs = vector()

#---------------PARSE READ MAPPING DATA-----------------#
con = file(file_reads, "r")
while ( TRUE ) {
	line = readLines(con, n = 1)
	if( (length(line) == 0) || (nchar(line) == 0) ){
		break
	}
	pieces = unlist(strsplit(line,"\t"))
	for (i in pieces[1]:pieces[2]){
		if(pieces[1] < pieces[2]){
			forward[i] <- forward[i]+1
		}else{
			reverse[i] <- reverse[i]+1
		}
	} 
}
close(con)

dat <- data.frame(
	Direction = c(rep("Forward", length(forward)), rep("Reverse", length(reverse))),
	x = rep(1:genome_length, 2),
	y = c(log10(forward+1), -log10(reverse+1))
)
p <- ggplot(dat, aes(x=x, y=y, fill=Direction)) + geom_bar(stat="identity", position="identity") + 
		labs(x="Position on Genome", y="Coverage (log10)", title="Read Mapping")


#---------------PARSE ORF MAPPING DATA-----------------#
if(file.exists(file_orfs) ){
	con = file(file_orfs, "r")
	while ( TRUE ) {
		line = readLines(con, n = 1)
		if( (length(line) == 0) || (nchar(line) == 0) ){
			break
		}
		pieces = unlist(strsplit(line,"\t"))
		start = strtoi(pieces[1])
		end = strtoi(pieces[2])
		if(start < end){
			p <- p + geom_segment(x=start, y=(start%%3)+1, xend=end, yend=(start%%3)+1)
		}else{
			p <- p + geom_segment(x=start, y=-((start%%3)+1), xend=end, yend=-((start%%3)+1))
		}
	}
	close(con)
}

#---------------PLOT THE DATA IN TIFF FORM-----------------#
if(args[1] == "-test"){
	tiff(filename="temp.tiff", width=8, height=4, units="in", res=600)
	print(p)
	invisible(dev.off())
	if(md5sum("temp.tiff") == md5sum("READ_MAPPINGS.TIFF")){
		cat("Passed 1/1 tests.\n")
	}
	unlink("temp.tiff")
}else{
	tiff(filename="figure.tiff", width=8, height=4, units="in", res=600)
	print(p)
	invisible(dev.off())
	cat("Output image: figure.tiff\n")
}

              
              
