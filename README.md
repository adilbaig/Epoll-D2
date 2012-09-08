Epoll For D
========

epoll is the fastest event subsystem on Linux ([http://man-wiki.net/index.php/4:epoll](http://man-wiki.net/index.php/4:epoll)). This api is a thin wrapper to the linux epoll api. It exposes all of epoll's facilities with a simpler interface that removes boiler plate without comprosing on epoll's options. 

The C interface is also publicly imported.

## Usage
	
	import epoll.epoll;
	
	//Create an EPoll struct
	EPoll epoll = EPoll(30); //maximum number of connections

	//Prepare an epoll_event, that tells epoll what events we're interested in listening to
	epoll_event ev;
	ev.events = EPOLL_EVENTS.IN | EPOLL_EVENTS.HUP | 	EPOLL_EVENTS.ERR; //Refer to the epoll documentation
	ev.data.fd = listener.handle(); //Optional

	//Watch a file descriptor (socket, file) for "ev.events" events
	epoll.add(int file_descriptor, ev);

	while(true)
	{
		// Now wait for events to occur
		foreach(epoll_event event; epoll.wait(-1))
		{
			//An event occured! Use the event struct to find out. Each "event" corresponds to one file descriptor.
		}
	}

For an example look at [scgi.d](https://github.com/adilbaig/Epoll-D2/blob/master/scgi.d) .

## Dependencies
EPoll is a modern Linux library. You should compile this on a recent Linux distro. Tested with dmd 2.059 on Linux 64bit (Ubuntu 12.04).

## Contributions
Please download and play with this project. Open tickets for bugs. Patches, feature requests, suggestiongs to improve the code, documentation, performance and anything else are very welcome.

Adil Baig
<br />Blog : [adilbaig.posterous.com](http://adilbaig.posterous.com)
<br />Twitter : [@aidezigns](http://twitter.com/aidezigns)


