#!/usr/bin/perl -w
# --
# updatelastcustomercontact.pl - update all tickets with last customer contact
# Copyright (C) 2001-2022 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# $origin: otrs - 8207d0f681adcdeb5c1b497ac547a1d9749838d5 - scripts/updatelastcustomercontact.pl
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

# use ../ as lib location
use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';

use strict;
use warnings;

use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::System::Encode;
use Kernel::System::Time;
use Kernel::System::DB;
use Kernel::System::Ticket;

# common objects
my %CommonObject = ();
$CommonObject{ConfigObject} = Kernel::Config->new();
$CommonObject{LogObject}    = Kernel::System::Log->new(
    LogPrefix => 'OTRS-updatelastcustomercontact.pl',
    %CommonObject
);
$CommonObject{MainObject}   = Kernel::System::Main->new(%CommonObject);
$CommonObject{EncodeObject} = Kernel::System::Encode->new(%CommonObject);
$CommonObject{TimeObject}   = Kernel::System::Time->new(%CommonObject);
$CommonObject{DBObject}     = Kernel::System::DB->new(%CommonObject);
$CommonObject{TicketObject} = Kernel::System::Ticket->new(%CommonObject);

# get all open tickets
my $SQL = "SELECT t.id FROM ticket t, ticket_state ts, ticket_state_type tst WHERE " .
    " t.ticket_state_id = ts.id AND ts.type_id = tst.id AND tst.name IN ('new', 'open', 'pending reminder', 'pending auto') ";
$CommonObject{DBObject}->Prepare( SQL => $SQL );

my @TicketIDs;
while ( my @Row = $CommonObject{DBObject}->FetchrowArray() ) {
    push @TicketIDs, $Row[0];
}
exit(0) if !@TicketIDs;

my $FieldText = $CommonObject{ConfigObject}->Get('Znuny4OTRSSortByLastContact::FreeTextUsed');
exit(0) if !$FieldText;

my $Field = $CommonObject{ConfigObject}->Get('Znuny4OTRSSortByLastContact::FreeTimeUsed');
exit(0) if !$Field;

# ticket loop
TICKETS:
for my $TicketID ( sort { $a <=> $b } @TicketIDs ) {
    my @ArticleIndex = $CommonObject{TicketObject}->ArticleIndex( TicketID => $TicketID );
    next TICKETS if !@ArticleIndex;

    # article loop
    ARTICLES:
    for my $ArticleID ( reverse sort { $a <=> $b } @ArticleIndex ) {
        my %Article = $CommonObject{TicketObject}->ArticleGet( ArticleID => $ArticleID );
        next ARTICLES if !%Article;
        next ARTICLES if $Article{SenderType} !~ /^(customer|agent)/;
        next ARTICLES if $Article{ArticleType} !~ /(extern|phone|fax|sms)/;

        # update last customer update timestamp
        my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $CommonObject{TimeObject}->SystemTime2Date(
            SystemTime => $CommonObject{TimeObject}->TimeStamp2SystemTime(
                String => $Article{Created},
            ),
        );

        # remember sender type
        $CommonObject{TicketObject}->TicketFreeTextSet(
            Counter  => $FieldText,
            Key      => 'Last Sender',
            Value    => $Article{SenderType},
            TicketID => $TicketID,
            UserID   => 1,
        );

        # set last sender time
        $CommonObject{TicketObject}->TicketFreeTimeSet(
            Prefix                               => 'TicketFreeTime',
            TicketID                             => $TicketID,
            Counter                              => $Field,
            UserID                               => 1,
            'TicketFreeTime' . $Field . 'Year'   => $Year,
            'TicketFreeTime' . $Field . 'Month'  => $Month,
            'TicketFreeTime' . $Field . 'Day'    => $Day,
            'TicketFreeTime' . $Field . 'Hour'   => $Hour,
            'TicketFreeTime' . $Field . 'Minute' => $Min,
            'TicketFreeTime' . $Field . 'Second' => $Sec,
        );

        last ARTICLES;
    }
}

exit(0);
