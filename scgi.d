import std.stdio,
       std.socket,
       epoll.epoll
;

void GenericServer(string host, ushort port)
{
    auto listener = new TcpSocket();
    scope(exit)listener.close();
    assert(listener.isAlive);
    listener.blocking = false;
    listener.bind(new InternetAddress(host, port));
    listener.listen(20);
    writefln("Listening on %s:%d.", host, port);
    
    const uint maxConnections = 30;
    
    epoll_event ev;
    ev.events = EPOLL_EVENTS.IN | EPOLL_EVENTS.HUP | EPOLL_EVENTS.ERR;
    ev.data.fd = listener.handle();
    
    auto epoll = EPoll(maxConnections);
    auto rez   = epoll.add(listener, ev);
    
    writefln("EPOLL FD : %d, EPOLL_CTL Result : %d", epoll.epfd, rez);
    
    Socket[int] read;
    
    while(true)
    {
        foreach(epoll_event event; epoll.wait(-1))
        {
            auto fd = event.data.fd;
            
            if (fd == listener.handle()
                && event.events & EPOLL_EVENTS.IN)
            {
                Socket conn = listener.accept();
                conn.blocking = false;
                read[conn.handle] = conn;
                
                ev.data.fd = conn.handle();
                epoll.add(conn, ev);
                
                writef("Received connection from %s .. ", conn.remoteAddress().toString());
            }
            else if(fd in read)
            {
                if(event.events & EPOLL_EVENTS.IN)
                {
                    try{
                        auto bytes = getRequest(read[fd]);
                        writeln("INCOMING : ", cast(string)bytes);
                        
                        auto connection = read[fd];
                        connection.send("Status: 200 OK\r\n");
                        connection.send("Content-Type: text/html\r\n");
                        connection.send("\r\n"); //Signals the end of headers
                        connection.send("<html><title>Receieved</title><body>"~cast(string)bytes~"</body></html>"); //Signals the end of headers
                        
                    }catch(Exception e)
                    {
                        writeln(e);
                    }
                }
                else if(event.events & EPOLL_EVENTS.ERR
                    || event.events & EPOLL_EVENTS.HUP)
                    writeln("Connection error");
                
                epoll.remove(fd);
                
                if(read[fd].isAlive)
                    read[fd].close();
                    
                read.remove(fd);
            }
        }
    }
}
    
    byte[] getRequest(Socket connection)
    {
        byte[1024 * 4] buff;
        byte[] rez;
        ulong len;
        
        do{
            len = connection.receive(buff);
            if (Socket.ERROR == len)
                throw new Exception("Connection error.");
            
            rez ~= buff[0 .. len];
        }while(len > buff.length);
        
        if (0 == rez.length)
            throw new Exception("Connection closed.");
            
        return rez;
    }
    
void main()
{
    GenericServer("localhost", 4444);
}