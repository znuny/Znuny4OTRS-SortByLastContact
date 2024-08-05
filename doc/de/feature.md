# Funktionalität

Sortiert die Tickets in der Queue-, Status- und Gesperrt-Ansicht nach dem letzten Kontakt.

Installieren Sie einfach das Paket und die Funktion wird automatisch aktiviert.

## Funktionen

Während der Installation wird das dynamische Feld `TicketLastCustomerContactTime` zur Speicherung der Zeit erstellt.

Um die letzte Kontaktzeit (TicketLastCustomerContactTime) für alle bestehenden Tickets zu aktualisieren, führen Sie bitte das Kommando `bin/znuny.Console.pl Znuny::SortByLastContact` als Znuny-User aus.

Dieses Feld wird standardmäßig für folgende Ansichten aktiviert:
* Ansicht nach Queue - AgentTicketQueue
* Ansicht gesperrte Tickets - AgentTicketLockedView
* Ansicht nach Status - AgentTicketStatusView

## Weitere Anpassungen

Zusätzlich kann das Feld `TicketLastCustomerContactTime` (Letzter Kundenkontakt) als Spalte in folgenden Übersichten hinzugefügt werden:

* Ansicht nach Status              => Ticket::Frontend::AgentTicketStatusView###DefaultColumns
* Ansicht nach Queue               => Ticket::Frontend::AgentTicketQueue###DefaultColumns
* Ansicht nach Verantwortlicher    => Ticket::Frontend::AgentTicketResponsibleView###DefaultColumns
* Ansicht nach Beobachtungslisten  => Ticket::Frontend::AgentTicketWatchView###DefaultColumns
* Ansicht nach gesperrten Tickets  => Ticket::Frontend::AgentTicketLockedView###DefaultColumns
* Ansicht nach Ticket-Eskalationen => Ticket::Frontend::AgentTicketEscalationView###DefaultColumns

Fügen Sie für die obigen genannten Systemkonfigurationsoptionen in einer neuen Zeile als Schlüssel `DynamicField_TicketLastCustomerContactTime` und als Inhalt `1` ein.
