SHELL := /bin/bash
clasify:
	echo "Starting classification"
	cd 03_classification && make run

run/%:
	@echo "Searching $*"
	@[[ -f $* ]] && echo "file exists" || echo "file does not exist, verify the name"
	@[[ -f $* ]]
	@echo "Executing $*"
	@echo "$*" > to_run.txt
	make clasify

https\://github.com/ccm-bioinfo/cambda2023/blob/main/%.csv:
	@echo "file detected: $*.csv"
	git pull
	make run/$*.csv

https\://github.com/ccm-bioinfo/cambda2023/blob/main/%.tsv:
	@echo "file detected: $*.tsv"
	git pull
	make run/$*.tsv

https\://github.com/ccm-bioinfo/cambda2023/blob/main/%.gz:
	@echo "file detected: $*.gz"
	@echo "unzipping $*.gz withouth removing the original file"
	gunzip -k $*.gz
	make run/$*
	@echo "removing $*"
	rm $*
