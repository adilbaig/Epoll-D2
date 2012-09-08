module epoll.epoll;

public import epoll.c;

/**
 * The EPoll struct represents an epoll "connection".
 */
struct EPoll
{
    int epfd;
    epoll_event[] events;
    
    /**
     * Get an epoll file descriptor that can handle upto "connections".
     */
    this(uint connections)
    {
        epfd = epoll_create(connections);
        events = new epoll_event[connections];
    }
    
    /**
     * Add a file descriptor (fd) to epoll
     */
    int add(int fd, ref epoll_event ev)
    {
        return epoll_ctl(epfd, EPOLL_CTL.ADD, fd, &ev);
    }
    
    /**
     * Modify an existing file descriptor (fd) that was added to epoll
     */
    int modify(int fd, ref epoll_event ev)
    {
        return epoll_ctl(epfd, EPOLL_CTL.MOD, fd, &ev);
    }
    
    int remove(int fd)
    {
        return epoll_ctl(epfd, EPOLL_CTL.DEL, fd, null);
    }
    
    /**
     * Wait for events on for a maximum time of timeout milliseconds. When an event 
     * is triggered "wait" will return an epoll_event[], with an entry for each file descriptor
     * that has been updated
     */
    epoll_event[] wait(int timeout)
    {
        int n = epoll_wait(epfd, events.ptr, cast(int)events.length, timeout);
        
        debug{ import std.stdio; writeln("Wait  : ",n); }
        
        if(n < 1)
            return null;
            
        return events[0 .. n];
    }
}