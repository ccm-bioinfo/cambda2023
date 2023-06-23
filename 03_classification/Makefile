SHELL := /bin/bash
data_preprocess:
	@echo "Preprocessing data"
	rm generated_data/* || true
	rm generated_imgs/* || true
	cd .. && python 03_classification/data_enrichment.py save

run_original_%: data_preprocess
	@echo "Running original data with $*"
	cd .. && python 03_classification/data_classify.py original $*

run_transposed_%: data_preprocess
	@echo "Running transposed data with $*"
	cd .. && python 03_classification/data_classify.py transposed $*

run_original: run_original_PowerTransformer run_original_QuantileTransformer run_original_LogAndPca
	echo "Original data completed"

run_transposed: run_transposed_PowerTransformer run_transposed_QuantileTransformer
	echo "Transposed data completed"

run: run_original run_transposed
	echo "All completed"
	rm generated_imgs-$(shell cat last_run.txt)/* || true
	rmdir generated_imgs-$(shell cat last_run.txt) || true
	mv generated_imgs generated_imgs-$(shell cat last_run.txt)
	cd .. && python 03_classification/summary.py $(shell cat last_run.txt)
	bash deploy.sh $(shell pwd)/$(shell cat last_run.txt)

deploy/%:
	@echo "verificando si existe el directorio $*"
	@[[ -d $* ]] && echo "existe" || echo "no existe el directorio '$*', verifique que el nombre sea correcto"
	@[[ -d $* ]]
	@echo "copiando datos"
	@bash deploy.sh $(shell pwd)/$*
