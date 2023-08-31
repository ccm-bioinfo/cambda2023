# AMR detection in city coassemblies

## Data

Everything related to this pipeline can be found in Chihuil:
`/botete/mvazquez/camda2023/us-cities/`:

- `b1-coassemblies/` contains coassemblies by city.
- `b2-coassemblies-classification/` has Kraken outputs and reports from the
coassemblies.
- `b3-coassemblies-extraction/` contains sequences that were classified as
_Escherichia_, _Enterobacter_ or _Klebsiella_, by Kraken.
- `b4-coassemblies-card/` stores RGI's outputs from the extractions.
- `genus-list.txt` is the list of genera of interest.
- `city-list.txt` is the list of US cities.
- `coassemblies-amr-counts.tsv` is the table of AMR gene counts by city and
genus from the coassemblies. On GitHub, you can find it here:
[`230628_us_coassemblies_card_counts.tsv`](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/data/230628_us_coassemblies_card_counts.tsv)
- `coassemblies-amr-presence.tsv` is the presence-absence table. On GitHub,
you can find it here:
[`230628_us_coassemblies_card_presence.tsv`](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/data/230628_us_coassemblies_card_presence.tsv)
- `coassemblies-amr-counts-strict.tsv` is analogous to `coassemblies-amr-counts.tsv`
using only strict results. On GitHub, you can find it here:
[`230831_us_coassemblies_card_counts_strict.tsv`](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/data/230831_us_coassemblies_card_counts_strict.tsv)
- `coassemblies-amr-presence-strict.tsv` is analogous to `coassemblies-amr-presence.tsv`
using only strict results. On GitHub, you can find it here:
[`230831_us_coassemblies_card_presence_strict.tsv`](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/data/230831_us_coassemblies_card_presence_strict.tsv)

## Steps

1. Define paths to the trimmed reads directory, the Kraken database, the
RGI database, the `extract_kraken_reads.py` script from
[KrakenTools](https://github.com/jenniferlu717/KrakenTools), and a directory
where contents will be saved.

```bash
set -e
readsdir="$HOME/camda2023/trimmed/"
krakendb="$HOME/camda2023/krakenDB/"
rgidb="$HOME/camda2023/localDB/"
extractor="$HOME/camda2023/krakentools/extract_kraken_reads.py"
currdir=$(pwd) # Or set to any directory where contents will be saved
```

2. Create symbolic links to the reads inside the `reads/` directory in
`${currdir}`.

```bash
mkdir -p reads
cd reads
parallel ln -fs {} {/} ::: ${readsdir}/*_{BAL,DEN,MIN,NYC,SAC,SAN}_*
cd ..
```

3. Create two list files, one with the list of cities, and another with the
list of genera.

```bash
echo {BAL,DEN,MIN,NYC,SAC,SAN} | tr ' ' '\n' > city-list.txt
echo En,Enterobacter,547 Es,Escherichia,561 Kl,Klebsiella,570 | tr ' ' '\n' \
  > genus-list.txt
```

4. Perform city coassembly with `megahit`.

```bash
mkdir -p b1-coassemblies/
cat city-list.txt | while read city; do
  if [[ ! -f b1-coassemblies/${city}.fa ]]; then
    
    echo ""
    echo $(date +"%D %T:") Assembling ${city}

    f1=$(ls reads/*_${city}_*_1.fastq.gz | paste -s -d ',')
    f2=$(echo ${f1} | sed -e "s/_1\./_2\./g")

    megahit -1 "${f1}" -2 "${f2}" \
      -t $(expr $(nproc) / 4 + 1) -o b1-coassemblies/${city} \
      --out-prefix ${city} --tmp-dir tmp/

    mv -v b1-coassemblies/${city}/${city}.contigs.fa b1-coassemblies/${city}.fa
    rm -rf b1-coassemblies/${city}/

  fi
done
```

5. Perform taxonomic classification of coassemblies with `kraken2`.

```bash
mkdir -p b2-coassemblies-classification/
cat city-list.txt | while read city; do

  if [[ ! -f "b2-coassemblies-classification/${city}.output" ]] || \
     [[ ! -f "b2-coassemblies-classification/${city}.report" ]]; then

    echo $(date +"%D %T:") ${city}

    kraken2 \
      --db ${krakendb} \
      --threads $(expr $(nproc) / 4 + 1) \
      --report b2-coassemblies-classification/${city}.report \
      --output b2-coassemblies-classification/${city}.output \
      b1-coassemblies/${city}.fa
  fi
done
```

6. Extract sequences that were classified as _Escherichia_, _Enterobacter_ or
_Klebsiella_.

```bash
cat genus-list.txt | while read line; do

  genid=${line%%,*}
  genus=${line#*,}; genus=${genus%%,*}
  taxid=${line##*,}
  echo $(date +"%D %T:") Extracting ${genus} reads

  parallel -j $(expr $(nproc) / 4 + 1) \
    ${extractor} \
    -k b2-coassemblies-classification/{}.output \
    -s b1-coassemblies/{}.fa \
    -t ${taxid} \
    -o b3-coassemblies-extraction/{}_${genid}.fa \
    -r b2-coassemblies-classification/{}.report \
    --include-children \
    < city-list.txt

  echo $(date +"%D %T:") Finished extracting ${genus} reads
done
```

7. Annotate extractions with RGI.

```bash
mkdir -p b4-coassemblies-card/
cd $(dirname ${rgidb})

parallel -uj $(expr $(nproc) / 48 + 1) rgi main --local --clean \
  -i us-cities/b3-coassemblies-extraction/{/.}.fa \
  -o us-cities/b4-coassemblies-card/{/.} \
  -a DIAMOND -n $(expr $(nproc) / 16 + 1) \
  --low_quality --include_nudge --include_loose \
  ::: us-cities/b3-coassemblies-extraction/*.fa

cd ${currdir}
parallel mv {} {.}.tsv ::: b4-coassemblies-card/*.txt
```

8. Create abundance and presence-absence tables with the
[`get-amr-counts.py`](https://github.com/ccm-bioinfo/cambda2023/blob/main/01_preprocessing/src/get-amr-counts.py)
script, as well as strict-only tables with the
[`get-amr-counts-strict.py`](https://github.com/ccm-bioinfo/cambda2023/blob/main/01_preprocessing/src/get-amr-counts-strict.py)
script.

```bash
python get-amr-counts.py b4-coassemblies-card/*.tsv
mv amr-counts.tsv coassemblies-amr-counts.tsv
mv amr-presence.tsv coassemblies-amr-presence.tsv
python get-amr-counts-strict.py b4-coassemblies-card/*.tsv
mv amr-counts-strict.tsv coassemblies-amr-counts-strict.tsv
mv amr-presence-strict.tsv coassemblies-amr-presence-strict.tsv
```

9. **TODO**: BLAST for genes not in CARD.
