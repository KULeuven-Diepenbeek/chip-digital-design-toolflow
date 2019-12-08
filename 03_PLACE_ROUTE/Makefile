
prepareDirs:
	mkdir -p work
	mkdir -p logs
	mkdir -p reports
	mkdir -p data

innovus: prepareDirs
	cd work; innovus -overwrite -log ../logs/innoFloorplan.log -cmd ../logs/innoFloorplan.cmdlog

innFloorplan: prepareDirs
		cd work; innovus -overwrite -init ../scripts/01_innFloorplan.tcl -log ../logs/innFloorplan.log -cmd ../logs/innFloorplan.cmdlog

innPowerAnalysis: prepareDirs
		cd work; innovus -overwrite -init ../scripts/02_innPowerAnalysis.tcl -log ../logs/innPowerAnalysis.log -cmd ../logs/innPowerAnalysis.cmdlog

innPlace: prepareDirs
		cd work; innovus -overwrite -init ../scripts/03_innPlace.tcl -log ../logs/innPlace.log -cmd ../logs/innPlace.cmdlog

innCts: prepareDirs
		cd work; innovus -overwrite -init ../scripts/04_innCts.tcl -log ../logs/innCts.log -cmd ../logs/innCts.cmdlog

innRoute: prepareDirs
		cd work; innovus -overwrite -init ../scripts/05_innRoute.tcl -log ../logs/innRoute.log -cmd ../logs/innRoute.cmdlog

innOptRoute: prepareDirs
	cd work; innovus -overwrite -init ../scripts/06_innOptRoute.tcl -log ../logs/innOptRoute.log -cmd ../logs/innOptRoute.cmdlog

clean:
	rm -rf work/ logs/ reports/ logs/ data/
