 # gcc $GPIO_BASE -Wall -o test_toggle test_toggle.c && sudo chown root test_toggle && sudo chmod +s test_toggle
 
CC=gcc
GPIO_BASE=-DGPIO_BASE=0x3f200000

all: test_toggle.c
	$(CC) $(GPIO_BASE) -Wall -o test_toggle test_toggle.c
	sudo chown root test_toggle
	sudo chmod +s test_toggle



