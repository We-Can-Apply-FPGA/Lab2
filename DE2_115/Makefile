all: compile flash
compile:
	quartus_sh --flow compile DE2_115 
flash:
	quartus_pgm -c "USB-Blaster" DE2_115.cdf
