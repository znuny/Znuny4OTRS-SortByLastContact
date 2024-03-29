![Znuny logo](https://www.znuny.com/assets/images/logo_small.png)

![Build status](https://badge.proxy.znuny.com/Znuny4OTRS-SortByLastContact/rel-7_0)

Znuny-SortByLastContact
=======================

Sort queue view, status view and locked view by last contact.

Just install the package and the feature will be enabled automatically.

**Feature List**

The package adds a dynamic field named *TicketLastCustomerContactTime* to store the values.
To update the last contact time for all existing tickets after the installation, execute `bin/otrs.Console.pl Znuny::SortByLastContact`.
This field is set as default value in:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus

Many thanks to MyHammer AG which made this possible.

**Installation**

Download the [package](https://addons.znuny.com/api/addon_repos/public/2373/latest) and install it via admin interface -> package manager.

**Prerequisites**

- Znuny 7.0

**Download**

Download the [latest version](https://addons.znuny.com/api/addon_repos/public/2373/latest).

**Commercial Support**

For this add-on and for Znuny in general visit [www.znuny.com](https://www.znuny.com). Looking forward to hear from you!

Enjoy!

Your Znuny Team!

[https://www.znuny.com/](https://www.znuny.com/)
