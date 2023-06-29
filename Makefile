SHELL := /bin/bash
clasify:
	echo "Starting classification"
	cd 03_classification && make run

all_folds:
	make 03_classification/generated_plots/results_fold4.txt
	make 03_classification/generated_plots/results_fold3.txt
	make 03_classification/generated_plots/results_fold2.txt
	make 03_classification/generated_plots/results_fold1.txt
	make 03_classification/generated_plots/results_fold0.txt
	@echo "All folds finished"

03_classification/generated_plots/results_fold%.txt: fold%
	@echo "Fold $* completed"

fold%: 03_classification/data_classify_with_preselection.py
	@echo "Starting data partitioning"
	python 03_classification/samples_selection.py $*
	@echo "Starting variables selection"
	cd 02_variable_selection/codes && bash nb_with_training.sh || echo "failed"
	@echo "Starting model training"
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
