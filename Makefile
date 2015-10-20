all: compile flash
compile:
	quartus_sh --flow compile Lab2
flash:
	quartus_pgm -c "USB-Blaster" Lab2.cdf
