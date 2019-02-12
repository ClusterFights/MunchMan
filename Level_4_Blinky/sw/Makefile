CC=gcc
GPIO_BASE=-DGPIO_BASE=0x3f200000

all: test_toggle data_test md5_tb md5_tb16 find md5_test ifind

test_toggle: test_toggle.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

data_test: data_test.c munchman8.c md5.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

md5_tb: md5_tb.c munchman8.c md5.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

md5_tb16: md5_tb16.c munchman16.c md5.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

find: find.c munchman16.c md5.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

ifind: ifind.c find_lib.c kbinput.c
	$(CC) $(GPIO_BASE) -Wall -O3 -o $@ $^
	sudo chown root $@
	sudo chmod +s $@

md5_test: md5_test.c md5.c
	$(CC) -Wall -O3 -o $@ $^

