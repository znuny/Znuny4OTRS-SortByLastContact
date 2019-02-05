# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_Znuny4OTRSSortByLastContact;

use strict;
use warnings;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'Ticket event module to update last customer contact timestamp after article create action.'} = 'Ticket Event Modul zum automatischen Setzen des Zeitstempels für den letzten Kunden-Kontakt nach Erstellung eines Artikels.';
    $Self->{Translation}->{'Default sort criteria for all queues displayed in the QueueView after sort by priority is done.'} = 'Standard Sortierkriterium für alle Queues innerhalb der Queue-Ansicht nachdem nach der Priorität sortiert wurde.';
    $Self->{Translation}->{'Queue sort by default.'} = 'Standard Sortierung der Queue.';

    $Self->{Translation}->{'Defines the default ticket order (after priority sort) in the status view of the agent interface. Up: oldest on top. Down: latest on top.'} = 'Definiert die Standard-Ticketreihenfolge (nach Prioritätensortierung) in der Statusansicht der Agentenoberfläche. Oben: Älteste oben. Unten: das Neueste oben drauf.';
    $Self->{Translation}->{'Defines the default ticket attribute for ticket sorting in the locked ticket view of the agent interface.'} = 'Definiert das Standard-Ticketattribut für die Ticketsortierung in der gesperrten Ticketansicht der Agentenoberfläche.';


    return 1;
}

1;
