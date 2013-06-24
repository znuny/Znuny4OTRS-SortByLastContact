Sort by last Contact
====================
Sort QueueView, StatusView and LockedView by last contact. 

Just install the package and the feature will be enabled automatically.

The installer creates a DyncamicFiled called 'TicketLastCustomerContactTime' to store the values. 
To update the last contact time (TicketLastCustomerContactTime) for all existing ticket, execute "scripts/updatelastcustomercontact.pl".
This field is set as Default value in:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewMailbox
* Frontend::Agent::Ticket::ViewStatus

Many thanks to Myhammer AG, which made this possible.

Installation
============
Download the package and install it via admin interface -> package manager.

Prerequisites
* OTRS 3.1 / 3.2

Download
========
For download see http://znuny.com/d/

Note:
The 3.0 Version is still available in the master_30 branch.
https://github.com/znuny/Znuny4OTRS-SortByLastContact/tree/master_30

Commercial Support
==================
For this extention and for OTRS in gerneral visit http://znuny.com. Looking forward to hear from you!


Enjoy!

 Your Znuny Team!
 http://znuny.com

