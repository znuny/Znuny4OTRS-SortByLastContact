![Znuny logo](https://www.znuny.com/assets/images/logo_small.png)

Znuny4OTRS-SortByLastContact
====================

Sort Queue view, Status view and Locked view by last contact.

Just install the package and the feature will be enabled automatically.

**Feature List**

The package adds a Dynamic Field named *TicketLastCustomerContactTime* to store the values.
To update the last contact time for all existing ticket after the installation, execute `bin/otrs.Console.pl Znuny::SortByLastContact`.
This field is set as Default value in:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus

Many thanks to Myhammer AG, which made this possible.

**Installation**

Download the [package](https://addons.znuny.com/api/addon_repos/public/1083/latest) and install it via admin interface -> package manager or use [Znuny4OTRS-Repo](https://www.znuny.com/add-ons/znuny4otrs-repository).


**Prerequisites**

- OTRS 6
- [Znuny4OTRS-Repo](https://www.znuny.com/add-ons/znuny4otrs-repository)

**Download**

Download the [latest version](https://addons.znuny.com/api/addon_repos/public/1083/latest).

**Commercial Support**

For this extension and for OTRS in general visit [https://www.znuny.com](https://www.znuny.com). Looking forward to hear from you!

Enjoy!

Your Znuny Team!

[https://www.znuny.com/](https://www.znuny.com/)
