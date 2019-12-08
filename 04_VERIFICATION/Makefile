prepareDirs:
	mkdir -p work
	mkdir -p logs
	mkdir -p reports
	mkdir -p data

lecLowPowerCheck: prepareDirs
	cd work; lec -lpgxl -verify -TclMode -dofile ../scripts/lecLowPowerCheck.tcl -logfile ../logs/lecLowPowerCheck.log
	#lec -lp -verify -nogui -dofile scripts/lecRtlCpfCheck.tcl -logfile logs/lecRtlCpfCheck.log

lecOptRouteVsCompile: prepareDirs
	cd work; lec -lpgxl -TclMode -dofile ../scripts/lecOptRouteVsCompile.tcl -logfile ../logs/lecOptRouteVsCompile.log

innVerify: prepareDirs
	cd work; innovus -overwrite -init ../scripts/innVerify.tcl -log ../logs/innPhysVerif.log -cmd ../logs/innPhysVerif.cmdlog

clean:
	rm -rf work/ logs/ reports/ logs/ data/
