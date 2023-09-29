all_folds:
	make Outputs/generated_plots/results_fold4.txt
	make Outputs/generated_plots/results_fold3.txt
	make Outputs/generated_plots/results_fold2.txt
	make Outputs/generated_plots/results_fold1.txt
	make Outputs/generated_plots/results_fold0.txt
	@echo "All folds finished"

Outputs/generated_plots/results_fold%.txt: fold%
	@echo "Fold $* completed"

fold%: Scripts/data_classify_with_preselection.py .venv/bin/activate
	@echo "Starting data partitioning"
	. .venv/bin/activate; python Scripts/samples_selection.py $*
	@echo "Starting variables selection"
	bash Scripts/nb_with_training.sh
	@echo "Starting model training"
	rm -rf Outputs/generated_plots/results_fold$*.txt || true
	. .venv/bin/activate; export FOLD=$*; export PLOT=true; export METHOD=MLP; python Scripts/data_classify_with_preselection.py
	. .venv/bin/activate; export FOLD=$*; export PLOT=true; export METHOD=SVC; python Scripts/data_classify_with_preselection.py
	. .venv/bin/activate; export FOLD=$*; export PLOT=true; export METHOD=KNN; python Scripts/data_classify_with_preselection.py


.venv/bin/activate: requirements.txt
	@echo "Creating virtual environment"
	python3 -m venv .venv
	@echo "Activating virtual environment"
	. .venv/bin/activate
	@echo "Installing requirements"
	. .venv/bin/activate; pip install -r requirements.txt
	@echo "Virtual environment created"