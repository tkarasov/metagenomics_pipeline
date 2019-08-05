
#this script counted the number of reads in each file and output. I then filtered for those with more than 30,000 reads.

for direc in `ls /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/swedish_samples`; do
echo $direc
my_fil=`ls $direc | grep R2`
for rec in $my_fil
do
num_rec=`zcat $direc/$rec | grep "^@" | wc -l`
echo $direc/rec, $num_rec >> swedish_count.txt
done
done


for direc in `ls /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/dc3000_infections`; do
echo $direc
my_fil=`ls /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/dc3000_infections/$direc | grep R2`
for rec in $my_fil
do
num_rec=`zcat /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/dc3000_infections/$direc/$rec | grep "^@" | wc -l`
echo $direc/rec, $num_rec >> dc3000_count.txt
done
done

for direc in `ls /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/hpa_infections/controlled_metagenomics`; do
echo $direc
my_fil=`ls $direc | grep R2`
for rec in $my_fil
do
num_rec=`zcat $direc/$rec | grep "^@" | wc -l`
echo $direc/rec, $num_rec >> /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/hpa_count.txt
done
done

#hpa all okay except for control


for direc in `ls /ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/german_samples`; do
echo $direc
my_fil=`ls $direc | grep R2`
for rec in $my_fil
do
num_rec=`zcat $direc/$rec | grep "^@" | wc -l`
echo $direc/rec, $num_rec >> german_count.txt
done
done