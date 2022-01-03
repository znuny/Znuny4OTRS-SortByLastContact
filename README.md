![Znuny logo](https://www.znuny.com/assets/images/logo_small.png)


![Build status](https://badge.proxy.znuny.com/Znuny4OTRS-SortByLastContact/rel-5_0)

Znuny4OTRS-SortByLastContact
====================

Sort QueueView, StatusView and LockedView by last contact.

Just install the package and the feature will be enabled automatically.

**Feature List**

The installer creates a DynamicField called 'TicketLastCustomerContactTime' to store the values.
To update the last contact time (TicketLastCustomerContactTime) for all existing ticket, execute "bin/otrs.Console.pl Znuny::SortByLastContact".
This field is set as Default value in:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus

Many thanks to Myhammer AG, which made this possible.

**Installation**

Download the package and install it via admin interface -> package manager.

**Prerequisites**

- OTRS 5.0

**Download**

For download see [https://www.znuny.com/en/#!/addons](https://www.znuny.com/en/#!/addons)

**Commercial Support**

For this extension and for OTRS in general visit [www.znuny.com](https://www.znuny.com). Looking forward to hear from you!

Enjoy!

 Your Znuny Team!

 [www.znuny.com](https://www.znuny.com)
