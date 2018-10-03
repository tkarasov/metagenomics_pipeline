#!/usr/bin/python

import sys
import time

def readseq(seqs,two = True):
        # Read first line
        line1 = seqs.readline().rstrip().split('\t')
        if line1 == ['']: # Check line has data, indicate EOF if necessary
            return 'EOF'
        # Store data
        header1 = line1[0]
        seq1 = line1[1]
        # check for fastq
        try:
            qual1 = line1[3]
        except IndexError:
            qual1 = ''
        read1 = [header1,seq1,qual1]
        # Check wether one or two lines must be read
        if not two:
            return read1
        
        # Repeat with second line
        line2 = seqs.readline().rstrip().split('\t')
        if line2 == ['']:
            return [read1,['','','']]
        header2 = line2[0]
        seq2 = line2[1]
        try:
            qual2 = line2[3]
        except IndexError:
            qual2 = ''
        read2 = [header2,seq2,qual2]
        return [read1,read2]

def checkpaired(reads,poutfile,soutfile):
        id1 = reads[0][0].split(sep)[0]
        id2 = reads[1][0].split(sep)[0]
        if id1 == id2:
            if reads[0][2] == '':
                poutfile.write(reads[0][0] + '\n' + reads[0][1] + '\n' +
                               reads[1][0] + '\n' + reads[1][1] + '\n' )
            else:
                poutfile.write(reads[0][0] + '\n' + reads[0][1] + '\n+\n' + reads[0][2] + '\n' +
                               reads[1][0] + '\n' + reads[1][1] + '\n+\n' + reads[1][2] + '\n')
            return True
        else:
            if reads[0][2] == '':
                soutfile.write(reads[0][0] + '\n' + reads[0][1] + '\n')
            else:
                soutfile.write(reads[0][0] + '\n' + reads[0][1] + '\n+\n' + reads[0][2] + '\n')
            return False



if not sys.stdin.isatty():
    seqs = sys.stdin
    sep = sys.argv[1]
    # determine outfile names from command line
    poutfile = open(sys.argv[2],'w')
    soutfile = open(sys.argv[3],'w')
else:
    sys.stdout.write("Read sequencing reads from STDIN and write paired and single reads\n")
    sys.exit()

#poutfile = open("paired_reads.fq",'w')
#soutfile = open("single_reads.fq",'w')

pairedFlag = True
while True:
    if pairedFlag:
        reads = readseq(seqs)
        if reads == 'EOF':
            break
        pairedFlag = checkpaired(reads,poutfile,soutfile)
    else:
        reads = [reads[1]]
        read = readseq(seqs,two=False)
        if read == 'EOF':
            if reads[0][2] == '':
                soutfile.write(reads[0][0] + '\n' + reads[0][1] + '\n')
            else:
                soutfile.write(reads[0][0] + '\n' + reads[0][1] + '\n+\n' + reads[0][2] + '\n')

            break
        reads.append(read)
        pairedFlag = checkpaired(reads,poutfile,soutfile)

poutfile.close()
soutfile.close()


        
