# Functionality

Tickets in the Queue, Status and Locked view were sorted by the last contact.

This feature is automatically enabled after package installation.


**Features**

The dynamic field 'TicketLastCustomerContactTime' is added to the system during the package installation. This field is needed to store the time of the last contact.

To update the last contact time for existing tickes (prior package installation) execute this command as the otrs user: "bin/otrs.Console.pl Znuny::SortByLastContact".

The dynamic field is added to this views:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus

## further adjustments

In addition, the field "TicketLastCustomerContactTime" can be added as a column in the following views:

Status View      => Frontend::Agent::Ticket::ViewStatus###DefaultColumns
Queue View       => Frontend::Agent::Ticket::ViewQueue###DefaultColumns
Responsible View => Frontend::Agent::Ticket::ViewResponsible###DefaultColumns
Watch View       => Frontend::Agent::Ticket::ViewWatch###DefaultColumns
Locked View      => Frontend::Agent::Ticket::ViewLocked###DefaultColumns
Escalation View  => Frontend::Agent::Ticket::ViewEscalation###DefaultColumns

In SysConfig add a row to the above mentioned configurations, with Key=DynamicField_TicketLastCustomerContactTime and Content=1.