![Znuny logo](https://www.znuny.com/assets/images/logo_small.png)

![Build status](https://badge.proxy.znuny.com/Znuny4OTRS-SortByLastContact/rel-7_2)

Znuny-SortByLastContact
=======================

Tickets in the queue, status and locked view will be sorted by the last contact.

This feature is automatically enabled after package installation.

The dynamic field `TicketLastCustomerContactTime` is added to the system during the package installation. This field is needed to store the time of the last contact.

To update the last contact time for existing tickets (prior package installation) execute command `bin/znuny.Console.pl Znuny::SortByLastContact` as Znuny user.

The dynamic field will be activated by default for the following views:
* View by queue - AgentTicketQueue
* Lock view - AgentTicketLockedView
* View by state - AgentTicketStatusView

Many thanks to MyHammer AG which made this possible.

**Prerequisites**

- Znuny 7.2

**Installation**

Use the online repository **Znuny Open Source Add-ons** from the package manager to install the add-on. From the command line use this command: `bin/znuny.Console.pl Admin::Package::Install  https://addons.znuny.com/public/:Znuny-SortByLastContact`

**Commercial Support**

For this add-on and for Znuny in general visit [www.znuny.com](https://www.znuny.com). Looking forward to hear from you.


Your Znuny Team!

[https://www.znuny.com](https://www.znuny.com)
