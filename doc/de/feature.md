# Znuny4OTRS-SortByLastContact

Sortiert die Tickets in der Queue-Ansicht, Status-Ansicht und Gesperrt-Ansicht nach dem letzten Kontakt.

Installieren Sie einfach das Paket und die Funktion wird automatisch aktiviert.

**Feature Liste**

Währen der Installation wird das dynamisches Feld "TicketLastCustomerContactTime" zur Speicherung der Zeit erstellt.

Um die letzte Kontaktzeit (TicketLastCustomerContactTime) für alle bestehenden Ticket zu aktualisieren, führen Sie bitte das "bin/otrs.Console.pl Znuny::SortByLastContact" Skript aus.

Dieses Feld wird als Standardwert in folgenden Ansichten gesetzt:
* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewLocked
* Frontend::Agent::Ticket::ViewStatus