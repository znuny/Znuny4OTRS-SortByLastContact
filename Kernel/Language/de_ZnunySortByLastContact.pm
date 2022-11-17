# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ZnunySortByLastContact;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;


    # SysConfig
    $Self->{Translation}->{"Defines the default sort criteria for all queues displayed in the queue view."} = "Definiert die Standardsortierkriterien für alle in der Queueansicht angezeigten Queues.";

    $Self->{Translation}->{"Defines the default ticket attribute for ticket sorting in the status view of the agent interface."} = "Definiert das Standard-Ticketattribut für die Ticket-Sortierung in der Statusansicht der Agentenschnittstelle.";

    $Self->{Translation}->{"Defines the default ticket order (after priority sort) in the status view of the agent interface. Up: oldest on top. Down: latest on top."} = "Definiert die Standard-Ticketreihenfolge (nach Sortierung der Priorität) in der Statusansicht der Agentenschnittstelle. Up: Älteste oben. Unten: spätestens an der Spitze.";

    $Self->{Translation}->{"Defines if a pre-sorting by priority should be done in the queue view."} = "Legt fest, ob eine Vorsortierung nach Priorität in der Queueansicht erfolgen soll.";

    $Self->{Translation}->{"Defines the default ticket attribute for ticket sorting in the locked ticket view of the agent interface."} = "Definiert das Standard-Ticketattribut für die Ticket-Sortierung in der gesperrten Ticketansicht der Agentenschnittstelle.";

    $Self->{Translation}->{"Ticket event module to update last customer contact timestamp after article create action."} = "Ticket Event Modul zum automatischen Setzen des Zeitstempels für den letzten Kunden-Kontakt nach Erstellung eines Artikels.";

    # Frontend
    $Self->{Translation}->{'TicketLastCustomerContactTime'}      = 'Letzter Kundenkontakt';
    $Self->{Translation}->{'TicketLastCustomerContactDirection'} = 'Letzter Kontakt durch';
    return 1;
}

1;
