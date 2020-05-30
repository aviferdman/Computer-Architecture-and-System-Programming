SRCS = mypipe.c
OBJS = $(SRCS:.c=.o)
MAIN = mypipe
CC = gcc
CFLAGS = -m32 -g -Wall

all: $(MAIN)

$(MAIN): $(OBJS) 
	$(CC) $(CFLAGS)  -o $(MAIN) $(OBJS)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<  -o $@


.PHONY: depend clean

clean:
	$(RM) *.o *~ $(MAIN)
