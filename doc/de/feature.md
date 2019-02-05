# Funktionalität

Sortieren Sie QueueView, StatusView und LockedView nach dem letzten Kontakt.

Installieren Sie einfach das Paket und die Funktion wird automatisch aktiviert.

Das Installationsprogramm erstellt ein DynamicField namens'TicketLastCustomerContactTime', um die Werte zu speichern.
Um die letzte Kontaktzeit (TicketLastCustomerContactTime) für alle vorhandenen Tickets zu aktualisieren, führen Sie "bin/znuny.UpdateLastCustomerContact.pl" aus.

Dieses Feld wird als Standardwert in gesetzt:

* Frontend::Agent::Ticket::ViewQueue
* Frontend::Agent::Ticket::ViewMailbox
* Frontend::Agent::Ticket::ViewStatus
