CC=gcc
GPIO_BASE=-DGPIO_BASE=0x3f200000

all: test_toggle data_test md5_tb

test_toggle: test_toggle.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

data_test: data_test.c munchman.c md5.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

md5_tb: md5_tb.c munchman.c md5.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

