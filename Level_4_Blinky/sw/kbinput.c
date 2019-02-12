#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <sys/select.h>
#include "kbinput.h"

static int kbinput_hit(time_t timeout_sec)
{
	fd_set fds;
	struct timeval tv;

	tv.tv_sec = timeout_sec;
	tv.tv_usec = 0;
	FD_ZERO(&fds);
	FD_SET(STDIN_FILENO, &fds);
	if (select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) < 0)
		return -1;

	// Return 1 if input is pending, otherwise 0.
	return FD_ISSET(STDIN_FILENO, &fds) ? 1 : 0;
}

int kbinput_read_block(time_t timeout_sec)
{
	int ret;
	unsigned char ch;
	static struct termios ios;
	static struct termios ios_save;
	tcflag_t save_clflags;

	// Disable buffering on stdin.
	tcgetattr(STDIN_FILENO, &ios);
	ios_save = ios;
	ios.c_lflag &= ~ICANON;
	tcsetattr(STDIN_FILENO, TCSANOW, &ios);

	// Default return value.
	ret = -1;

	// Is input pending?
	if (kbinput_hit(timeout_sec) > 0) {
		ret = read(STDIN_FILENO, &ch, 1);
		if (ret == 1)
			ret = (int) ch;
	}

	// Restore stdin to default state.
	tcsetattr(STDIN_FILENO, TCSANOW, &ios_save);

	// Return character value, or -1 if no character or error.
	return ret;
}

int kbinput_read(void)
{
	return kbinput_read_block(0);
}

