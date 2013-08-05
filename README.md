![Znuny logo](http://znuny.com/assets/logo_small.png)

Znuny4OTRS-SortByLastContact
====================

Sort QueueView, StatusView and LockedView by last contact. 

Just install the package and the feature will be enabled automatically.

**Feature List**

The installer creates a DyncamicFiled called 'TicketLastCustomerContactTime' to store the values. 
To update the last contact time (TicketLastCustomerContactTime) for all existing ticket, execute "scripts/updatelastcustomercontact.pl".
This field is set as Default value in:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewMailbox
* Frontend::Agent::Ticket::ViewStatus

Many thanks to Myhammer AG, which made this possible.

**Installation**

Download the package and install it via admin interface -> package manager.

**Prerequisites**

- OTRS 3.1

- OTRS 3.2

**Download**

For download see [http://znuny.com/d/](http://znuny.com/d/)

**Commercial Support**

For this extension and for OTRS in general visit [http://znuny.com](http://znuny.com). Looking forward to hear from you!

Enjoy!

 Your Znuny Team!

 [http://znuny.com](http://znuny.com)


