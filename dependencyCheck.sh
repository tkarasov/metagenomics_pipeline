#!/bin/bash
check_dep(){
printf "Checking for script dependencies\n"


bwaPTH=$(which bwa)
if [ $? -eq 0 ]
then
    printf "bwa found in $bwaPTH\n"
else
    printf "bwa not found, compiling...\n"
    cd bwa
    make > compileBWAout 2>&1
    PATH=$(pwd):$PATH
    cd ..
    bwaPTH=$(which bwa)
    printf "\n\nbwa compiled, you can find it in:$bwaPTH\n"
fi

samtoolsPTH=$(which samtools)
if [ $? -eq 0 ]
then
    printf "samtools found in $samtoolsPTH\n"
    samVersion=$(samtools &> /dev/stdout  | grep Version | cut -f2 -d ' '| cut -c1,2,3)
    if [ $samVersion == "1.6" ]
    then
        command
    else
        printf "You have an old version of samtools ($samVersion) , updating to latest version (1.6)\n"
        install_samtools
    fi
else
    printf "samtools not found, compiling...\n"
    install_samtools 
fi


javaPTH=$(which java)
if [ $? -eq 0 ]
then
    printf "java found in $javaPTH\n"
    printf "checking java version\n"
    version=$(java -version &> /dev/stdout | head -1)
    if [[ $version == *"1.8"* ]]
    then 
        printf "$version\n"
    else 
        printf "$version\nNot compatible version of java, please install java 1.8\n"
        return 1
    fi
else
    printf "java not found please install java 1.8\n"
    return 1
fi

while true
do
    printf "Is picardtools installed in your system? [y/N]\n"
    read answer
    if [ $answer == 'y' ] || [ $answer == 'Y' ]
    then
        printf "Please specify the location of picard.jar eg. /Home/User/Downloads/picard.jar\n"
        read location
        if [ -e $location ]
        then
            picard=$(readlink -f $location)
            break
        else
            printf "$location could not be found, please specify a correct path\n"
        fi
    elif [ $answer == 'n' ] || [ $answer == 'N' ]
    then
        printf "Downloading picard.jat from https://github.com/broadinstitute/picard/releases/download/2.17.3/picard.jar\n"
        wget https://github.com/broadinstitute/picard/releases/download/2.17.3/picard.jar > picardDOWNLOAD.out 2>&1
        picard=$(readlink -f picard.jar)
        break
    else
        printf "Answer y or n\n"
    fi
done


printf "Compiling seqstats\n"
cd seqstats
make > seqstatsMAKEout 2>&1
PATH=$PATH:$(pwd)
cd ..


diamondPTH=$(which diamond)
if [ $? -eq 0 ]
then
    printf "diamond found in $diamondPTH\n"
else
    install_diamond    
fi
}

install_diamond(){
    printf "diamond not found, compiling...\n"
    cd diamond
    mkdir -p bin 
    cd bin
    cmake .. > diamondCOMPILEout 2>&1
    make >> diamondCOMPILEout 2>&1
    PATH=$(pwd):$PATH
    cd ../..
    diamondPTH=$(which diamond)
    printf "\n\ndiamond compiled, you can find it in:$diamondPTH\n"
}

install_samtools(){
    printf "compiling htslib..."
    sleep 3
    cd htslib
    make clean > samtoolsCOMPILEout 2>&1
    autoheader > samtoolsCOMPILEout 2>&1
    autoconf > samtoolsCOMPILEout 2>&1
    ./configure --prefix=$(pwd) > samtoolsCOMPILEout 2>&1
    make > samtoolsCOMPILEout 2>&1
    make install > samtoolsCOMPILEout 2>&1
    cd ..
    printf "compiling samtools..."
    cd samtools
    make clean > samtoolsCOMPILEout 2>&1
    autoheader > samtoolsCOMPILEout 2>&1
    autoconf -Wno-syntax > samtoolsCOMPILEout 2>&1
    ./configure --prefix=$(pwd) > samtoolsCOMPILEout 2>&1
    make > samtoolsCOMPILEout 2>&1
    make install > samtoolsCOMPILEout 2>&1
    cd bin
    PATH=$(pwd):$PATH
    samtoolsPTH=$(which samtools)
    printf "\n\nsamtools compiled, you can find it in:$samtoolsPTH\n"
    cd ../..
}

printf "This script will check for all the necessary software
 required to run metagenomic_scripts. If any software is not
 found in your system, it will be downloaded and compiled.
 Additionally, your PATH environmental vairable will be modified
 in order to run all programs.\nDo you wish to continue? [y/N]\n"

while true
do
    read answer
    if [ -z $answer ] || [ $answer == "n" ] || [ $answer == "N" ]
    then
        command
        break
    elif [ $answer == "y" ] || [ $answer == "Y" ]
    then
        check_dep
        break
    else
        printf "Do you wich to continue? [y/N]\n"
    fi
done




