# Funktionalität

Sortiert die Tickets in der Queue-Ansicht, Status-Ansicht und Gesperrt-Ansicht nach dem letzten Kontakt.

Installieren Sie einfach das Paket und die Funktion wird automatisch aktiviert.


**Feature Liste**

Währen der Installation wird das dynamisches Feld "TicketLastCustomerContactTime" zur Speicherung der Zeit erstellt.

Um die letzte Kontaktzeit (TicketLastCustomerContactTime) für alle bestehenden Tickets zu aktualisieren, führen Sie bitte das "bin/otrs.Console.pl Znuny::SortByLastContact" Skript als OTRS User aus.

Dieses Feld wird als Standardwert in folgenden Ansichten gesetzt:
* Ansicht nach Queue - AgentTicketQueue
* Ansicht gesperrte Tickets - AgentTicketLockedView
* Ansicht nach Status - AgentTicketStatusView

## weitere Anpassungen

Zusätzlich kann das Feld "TicketLastCustomerContactTime" (Letzter Kundenkontakt) als Spalte in folgenden Übersichten hinzugefügt werden:
Ansicht nach Status              => Ticket::Frontend::AgentTicketStatusView###DefaultColumns
Ansicht nach Queue               => Ticket::Frontend::AgentTicketQueue###DefaultColumns
Ansicht nach Verantwortlicher    => Ticket::Frontend::AgentTicketResponsibleView###DefaultColumns
Ansicht nach Beobachtungslisten  => Ticket::Frontend::AgentTicketWatchView###DefaultColumns
Ansicht nach gesperrten Tickets  => Ticket::Frontend::AgentTicketLockedView###DefaultColumns
Ansicht nach Ticket-Eskalationen => Ticket::Frontend::AgentTicketEscalationView###DefaultColumns

In der SysConfig fügen Sie für die obigen genannten Konfigurationen in einer neuen Zeile als Schlüssel= DynamicField_TicketLastCustomerContactTime und als Inhalt=1 ein.