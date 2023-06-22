SHELL := /bin/bash
clasify:
	echo "Compilando clasificacion"
	cd clasificacion && make run

run/%:
	@echo "buscando $*"
	@[[ -f $* ]] && echo "existe" || echo "no existe el archivo '$*', verifique que el nombre sea correcto"
	@[[ -f $* ]]
	@echo "ejecutando $*"
	@echo "$*" > to_run.txt
	make clasify

https\://github.com/ccm-bioinfo/cambda2023/blob/main/%.csv:
	@echo "archivo detectado: $*.csv"
	git pull
	make run/$*.csv

https\://github.com/ccm-bioinfo/cambda2023/blob/main/%.tsv:
	@echo "archivo detectado: $*.tsv"
	git pull
	make run/$*.tsv
