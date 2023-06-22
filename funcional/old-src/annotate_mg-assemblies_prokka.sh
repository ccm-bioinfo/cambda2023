# Usage: ./prokka-assemblies.sh

cd $(dirname "$(dirname "$(readlink -f $0)")")

ls data/01-assemblies/01-metagenomes/* | while read assembly_file; do
  base=$(basename ${assembly_file%%.fasta})
  prokka --outdir data/02-annotations/01-prokka/01-metagenomes/${base} \
    --norrna --notrna --prefix ${base} --metagenome --cpus 16 ${assembly_file}
done
