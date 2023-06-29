SHELL := /bin/bash
clasify:
	echo "Starting classification"
	cd 03_classification && make run

fold%:
	@echo "Starting data partitioning"
	python 03_classification/samples_selection.py $*
	@echo "Starting variables selection"
	cd 02_variable_selection/codes && bash nb_with_training.sh || echo "failed"
	@echo "Starting model training"
	@date >> log
	@echo "Starting model training (fold $*)" >> log
	export FOLD=$* && export PLOT=true && python 03_classification/data_classify_with_preselection.py

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
