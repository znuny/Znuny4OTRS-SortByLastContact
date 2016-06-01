# Znuny4OTRS-SortByLastContact

Sortiert die Tickets in der Queue-Ansicht, Status-Ansicht und Gesperrt-Ansicht nach dem letzten Kontakt.

Installieren Sie einfach das Paket und die Funktion wird automatisch aktiviert.


**Feature Liste**

Währen der Installation wird das dynamisches Feld "TicketLastCustomerContactTime" zur Speicherung der Zeit erstellt.

Um die letzte Kontaktzeit (TicketLastCustomerContactTime) für alle bestehenden Tickets zu aktualisieren, führen Sie bitte das "bin/otrs.Console.pl Znuny::SortByLastContact" Skript aus.

Dieses Feld wird als Standardwert in folgenden Ansichten gesetzt:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus

## weitere Anpassungen

Zusätzlich kann das Feld "TicketLastCustomerContactTime" (Letzter Kundenkontakt) als Spalte in folgenden Übersichten hinzugefügt werden:

Ansicht nach Status              => Frontend::Agent::Ticket::ViewStatus###DefaultColumns
Ansicht nach Queue               => Frontend::Agent::Ticket::ViewQueue###DefaultColumns
Ansicht nach Verantwortlicher    => Frontend::Agent::Ticket::ViewResponsible###DefaultColumns
Ansicht nach Beobachtungslisten  => Frontend::Agent::Ticket::ViewWatch###DefaultColumns
Ansicht nach gesperrten Tickets  => Frontend::Agent::Ticket::ViewLocked###DefaultColumns
Ansicht nach Ticket-Eskalationen => Frontend::Agent::Ticket::ViewEscalation###DefaultColumns

In der SysConfig fügen Sie für die obigen genannten Konfigurationen in einer neuen Zeile als Schlüssel= DynamicField_TicketLastCustomerContactTime und als Inhalt=1 ein.