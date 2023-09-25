# Functionality

Tickets in the Queue, Status and Locked view were sorted by the last contact.

This feature is automatically enabled after package installation.


**Features**

The dynamic field 'TicketLastCustomerContactTime' is added to the system during the package installation. This field is needed to store the time of the last contact.

To update the last contact time for existing tickes (prior package installation) execute this command as the znuny user: "bin/znuny.Console.pl Znuny::SortByLastContact".

The dynamic field is added to this views:
* View by Queue - AgentTicketQueue
* Lock view - AgentTicketLockedView
* Vie by State - AgentTicketStatusView

## further adjustments

In addition, the field "TicketLastCustomerContactTime" can be added as a column in the following views:

Status View      => Ticket::Frontend::AgentTicketStatusView###DefaultColumns
Queue View       => Ticket::Frontend::AgentTicketQueue###DefaultColumns
Responsible View => Ticket::Frontend::AgentTicketResponsibleView###DefaultColumns
Watch View       => Ticket::Frontend::AgentTicketWatchView###DefaultColumns
Locked View      => Ticket::Frontend::AgentTicketLockedView###DefaultColumns
Escalation View  => Ticket::Frontend::AgentTicketEscalationView###DefaultColumns

In SysConfig add a row to the above mentioned configurations, with Key=DynamicField_TicketLastCustomerContactTime and Content=1.