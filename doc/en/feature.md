# Functionality

Tickets in the queue, status and locked view will be sorted by the last contact.

This feature is automatically enabled after package installation.

## Functions

The dynamic field `TicketLastCustomerContactTime` is added to the system during the package installation. This field is needed to store the time of the last contact.

To update the last contact time for existing tickets (prior package installation) execute command `bin/znuny.Console.pl Znuny::SortByLastContact` as Znuny user.

The dynamic field will be activated by default for the following views:
* View by queue - AgentTicketQueue
* Lock view - AgentTicketLockedView
* View by state - AgentTicketStatusView

## Further adjustments

In addition, the field `TicketLastCustomerContactTime` can be added as a column to the following views:

* Status View      => Ticket::Frontend::AgentTicketStatusView###DefaultColumns
* Queue View       => Ticket::Frontend::AgentTicketQueue###DefaultColumns
* Responsible View => Ticket::Frontend::AgentTicketResponsibleView###DefaultColumns
* Watch View       => Ticket::Frontend::AgentTicketWatchView###DefaultColumns
* Locked View      => Ticket::Frontend::AgentTicketLockedView###DefaultColumns
* Escalation View  => Ticket::Frontend::AgentTicketEscalationView###DefaultColumns

Add a row to the above mentioned system configuration options with Key `DynamicField_TicketLastCustomerContactTime` and Content `1`.
