# Znuny4OTRS-SortByLastContact

Tickets in the Queue, Status and Locked view were sorted by the last contact.

This feature is automatically enabled after package installation.


**Features**

The dynamic field 'TicketLastCustomerContactTime' is added to the system during the package installation. This field is needed to store the time of the last contact.

To update the last contact time for existing tickes (prior package installation) execute this command as the otrs user: "bin/otrs.Console.pl Znuny::SortByLastContact".

The dynamic field is added to this views:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus