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

use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{"Queue sort by default."} = "Standard Sortierung der Queue.";
    $Self->{Translation}->{"Ticket event module to update last customer contact timestamp after article create action."} = "Ticket Event Modul zum automatischen Setzen des Zeitstempels für den letzten Kunden-Kontakt nach Erstellung eines Artikels.";
    $Self->{Translation}->{'TicketLastCustomerContactTime'} = 'Letzter Kundenkontakt';
    $Self->{Translation}->{'TicketLastCustomerContactDirection'} = 'Letzter Kontakt durch';
    return 1;
}

1;
