/**
 * Interface to epoll
 */
module epoll.c;

enum
{
    EPOLL_CLOEXEC  = 0x80000,
    EPOLL_NONBLOCK = 0x800
};

enum EPOLL_EVENTS
{
    IN = 0x001,
    PRI = 0x002,
    OUT = 0x004,
    RDNORM = 0x040,
    RDBAND = 0x080,
    WRNORM = 0x100,
    WRBAND = 0x200,
    MSG = 0x400,
    ERR = 0x008,
    HUP = 0x010,
    RDHUP = 0x2000,
    ONESHOT = 1u << 30,
    ET = 1u << 31
};

/* Valid opcodes ( "op" parameter ) to issue to epoll_ctl().  */
enum EPOLL_CTL : ubyte
{
    ADD = 1, // Add a file decriptor to the interface.
    DEL = 2, // Remove a file decriptor from the interface.
    MOD = 3, // Change file decriptor epoll_event structure.
};

struct epoll_event 
{ 
     uint events;
     epoll_data_t data;
};

private union epoll_data_t 
{
    void *ptr;
    int fd;
    uint u32;
    ulong u64;
};
 

/* Creates an epoll instance.  Returns an fd for the new instance.
   The "size" parameter is a hint specifying the number of file
   descriptors to be associated with the new instance.  The fd
   returned by epoll_create() should be closed with close().  */
extern (C) int epoll_create (int size);

/* Same as epoll_create but with an FLAGS parameter.  The unused SIZE
   parameter has been dropped.  */
extern (C) int epoll_create1 (int flags);


/* Manipulate an epoll instance "epfd". Returns 0 in case of success,
   -1 in case of error ( the "errno" variable will contain the
   specific error code ) The "op" parameter is one of the EPOLL_CTL_*
   constants defined above. The "fd" parameter is the target of the
   operation. The "event" parameter describes which events the caller
   is interested in and any associated user data.  
*/
extern (C) int epoll_ctl (int epfd, int op, int fd, epoll_event *event);


/* Wait for events on an epoll instance "epfd". Returns the number of
   triggered events returned in "events" buffer. Or -1 in case of
   error with the "errno" variable set to the specific error code. The
   "events" parameter is a buffer that will contain triggered
   events. The "maxevents" is the maximum number of events to be
   returned ( usually size of "events" ). The "timeout" parameter
   specifies the maximum wait time in milliseconds (-1 == infinite).
*/
extern (C) int epoll_wait (int epfd, epoll_event *events, int maxevents, int timeout);


/* Same as epoll_wait, but the thread's signal mask is temporarily
   and atomically replaced with the one provided as parameter.
*/
//extern (C) int epoll_pwait (int epfd, epoll_event *events, int maxevents, int timeout, __const __sigset_t *__ss);
