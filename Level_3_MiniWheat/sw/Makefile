CC=gcc
GPIO_BASE=-DGPIO_BASE=0x3f200000

all: test_toggle data_test

test_toggle: test_toggle.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o test_toggle test_toggle.c
	sudo chown root test_toggle
	sudo chmod +s test_toggle

data_test: data_test.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o data_test data_test.c munchman.c md5.c
	sudo chown root data_test
	sudo chmod +s data_test


