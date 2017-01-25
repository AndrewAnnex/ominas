#!/usr/bin/env bash
#script to download and prepare for use a copy of the UCAC4 catalog from CDS
#Usage:
#./download_UCAC4.sh /directory/to/place/catalog


echo "This script wiill download the UCAC4 catalog from CDS (ftp://cdsarc.u-strasbg.fr/pub/cats/more/UCAC4/u4b/) and prepare its files for use. As of January/2017, this adds to 2.8 GB"

read -rp "Continue? " ans
case $ans in
  [Nn]*)
    exit
esac



baseurlb="ftp://cdsarc.u-strasbg.fr/pub/cats/more/UCAC4/u4b/" #binary files
baseurli="ftp://cdsarc.u-strasbg.fr/pub/cats/more/UCAC4/u4i/" #index and text files

#standard download (full, nonrecursive) directories

#location for timestamps files
mkdir -p ~/.ominas/timestamps/UCAC4

./pp_wget "${baseurli}/ --localdir=$1/${dir}/ --absolute --timestamps=~/.ominas/timestamps/ $@"
./pp_wget "${baseurlb}/ --localdir=$1/${dir}/ --absolute --timestamps=~/.ominas/timestamps/ $@"

