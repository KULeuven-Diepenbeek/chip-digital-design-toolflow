prepareDirs:
	mkdir -p work
	mkdir -p logs
	mkdir -p reports
	mkdir -p data

lecRtlCpfCheck: prepareDirs
	cd work; lec -lpgxl -verify -TclMode -dofile ../scripts/lecRtlCpfCheck.tcl -logfile ../logs/lecRtlCpfCheck.log
	#lec -lp -verify -nogui -dofile scripts/lecRtlCpfCheck.tcl -logfile logs/lecRtlCpfCheck.log

synthesis: prepareDirs
	cd work; genus -files ../scripts/synthesis.tcl -legacy_ui -log ../logs/synthesis.log -overwrite

lecCpfCheck:
	cd work; lec -lpgxl -verify -TclMode -dofile ../scripts/lecCpfCheck.tcl -logfile ../logs/lecCpfCheck.log
		#lec -lp -verify -nogui -dofile scripts/lecCpfCheck.tcl -logfile logs/lecCpfCheck.log

clean:
	rm -rf logs work reports data
