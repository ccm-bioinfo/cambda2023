all_folds:
	make 03_classification/generated_plots/results_fold4.txt
	make 03_classification/generated_plots/results_fold3.txt
	make 03_classification/generated_plots/results_fold2.txt
	make 03_classification/generated_plots/results_fold1.txt
	make 03_classification/generated_plots/results_fold0.txt
	@echo "All folds finished"

03_classification/generated_plots/results_fold%.txt: fold%
	@echo "Fold $* completed"

fold%: 07_reproducible_code/Scripts/data_classify_with_preselection.py
	@echo "Starting data partitioning"
	python 07_reproducible_code/Scripts/samples_selection.py $*
	@echo "Starting variables selection"
	cd 02_variable_selection/codes && bash nb_with_training.sh || echo "failed"
	@echo "Starting model training"
	rm -rf 03_classification/generated_plots/results_fold$*.txt || echo "failed"
	export FOLD=$* && export PLOT=true && export METHOD=MLP && python 07_reproducible_code/Scripts/data_classify_with_preselection.py
	export FOLD=$* && export PLOT=true && export METHOD=SVC && python 07_reproducible_code/Scripts/data_classify_with_preselection.py
	export FOLD=$* && export PLOT=true && export METHOD=KNN && python 07_reproducible_code/Scripts/data_classify_with_preselection.py