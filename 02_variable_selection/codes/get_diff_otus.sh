#!/bin/bash

echo "1 5"
Rscript most_diff_otus.R -m p
Rscript most_diff_otus.R -m nb
Rscript most_diff_otus.R -m zip
Rscript most_diff_otus.R -m zinb
Rscript most_diff_otus.R -m best

echo "2 5"
Rscript most_diff_otus.R -k TRUE -m p
Rscript most_diff_otus.R -k TRUE -m nb
Rscript most_diff_otus.R -k TRUE -m zip
Rscript most_diff_otus.R -k TRUE -m zinb
Rscript most_diff_otus.R -k TRUE -m best

echo "3 5"
Rscript most_diff_otus.R -R TRUE -m p
Rscript most_diff_otus.R -R TRUE -m nb
Rscript most_diff_otus.R -R TRUE -m zip
Rscript most_diff_otus.R -R TRUE -m zinb
Rscript most_diff_otus.R -R TRUE -m best

echo "4 5"
Rscript most_diff_otus.R -R TRUE -k TRUE -m p
Rscript most_diff_otus.R -R TRUE -k TRUE -m nb
Rscript most_diff_otus.R -R TRUE -k TRUE -m zip
Rscript most_diff_otus.R -R TRUE -k TRUE -m zinb
Rscript most_diff_otus.R -R TRUE -k TRUE -m best

echo "5 5"
Rscript most_diff_otus.R -u TRUE -m p
Rscript most_diff_otus.R -u TRUE -m nb
Rscript most_diff_otus.R -u TRUE -m zip
Rscript most_diff_otus.R -u TRUE -m zinb
Rscript most_diff_otus.R -u TRUE -m best

echo "6 5"
Rscript most_diff_otus.R -u TRUE -k TRUE -m p
Rscript most_diff_otus.R -u TRUE -k TRUE -m nb
Rscript most_diff_otus.R -u TRUE -k TRUE -m zip
Rscript most_diff_otus.R -u TRUE -k TRUE -m zinb
Rscript most_diff_otus.R -u TRUE -k TRUE -m best

echo "7 5"
Rscript most_diff_otus.R -u TRUE -R TRUE -m p
Rscript most_diff_otus.R -u TRUE -R TRUE -m nb
Rscript most_diff_otus.R -u TRUE -R TRUE -m zip
Rscript most_diff_otus.R -u TRUE -R TRUE -m zinb
Rscript most_diff_otus.R -u TRUE -R TRUE -m best

echo "8 5"
Rscript most_diff_otus.R -u TRUE -R TRUE -k TRUE -m p
Rscript most_diff_otus.R -u TRUE -R TRUE -k TRUE -m nb
Rscript most_diff_otus.R -u TRUE -R TRUE -k TRUE -m zip
Rscript most_diff_otus.R -u TRUE -R TRUE -k TRUE -m zinb
Rscript most_diff_otus.R -u TRUE -R TRUE -k TRUE -m best

echo "9 5"
Rscript most_diff_otus.R -r FALSE -m p
Rscript most_diff_otus.R -r FALSE -m nb
Rscript most_diff_otus.R -r FALSE -m zip
Rscript most_diff_otus.R -r FALSE -m zinb
Rscript most_diff_otus.R -r FALSE -m best

echo "10 5"
Rscript most_diff_otus.R -r FALSE -k TRUE -m p
Rscript most_diff_otus.R -r FALSE -k TRUE -m nb
Rscript most_diff_otus.R -r FALSE -k TRUE -m zip
Rscript most_diff_otus.R -r FALSE -k TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -k TRUE -m best

echo "11 5"
Rscript most_diff_otus.R -r FALSE -R TRUE -m p
Rscript most_diff_otus.R -r FALSE -R TRUE -m nb
Rscript most_diff_otus.R -r FALSE -R TRUE -m zip
Rscript most_diff_otus.R -r FALSE -R TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -R TRUE -m best

echo "12 5"
Rscript most_diff_otus.R -r FALSE -R TRUE -k TRUE -m p
Rscript most_diff_otus.R -r FALSE -R TRUE -k TRUE -m nb
Rscript most_diff_otus.R -r FALSE -R TRUE -k TRUE -m zip
Rscript most_diff_otus.R -r FALSE -R TRUE -k TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -R TRUE -k TRUE -m best

echo "13 5"
Rscript most_diff_otus.R -r FALSE -u TRUE -m p
Rscript most_diff_otus.R -r FALSE -u TRUE -m nb
Rscript most_diff_otus.R -r FALSE -u TRUE -m zip
Rscript most_diff_otus.R -r FALSE -u TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -u TRUE -m best

echo "14 5"
Rscript most_diff_otus.R -r FALSE -u TRUE -k TRUE -m p
Rscript most_diff_otus.R -r FALSE -u TRUE -k TRUE -m nb
Rscript most_diff_otus.R -r FALSE -u TRUE -k TRUE -m zip
Rscript most_diff_otus.R -r FALSE -u TRUE -k TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -u TRUE -k TRUE -m best

echo "15 5"
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -m p
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -m nb
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -m zip
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -m best

echo "16 5"
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -k TRUE -m p
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -k TRUE -m nb
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -k TRUE -m zip
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -k TRUE -m zinb
Rscript most_diff_otus.R -r FALSE -u TRUE -R TRUE -k TRUE -m best
