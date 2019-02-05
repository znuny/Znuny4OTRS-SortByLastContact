#!/usr/bin/perl
# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';

use Kernel::System::ObjectManager;

# create common objects
local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'OTRS-znuny.UpdateLastCustomerContact.pl',
    },
);

my $DBObject                  = $Kernel::OM->Get('Kernel::System::DB');
my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
my $TimeObject                = $Kernel::OM->Get('Kernel::System::Time');
my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

# get all open tickets
$DBObject->Prepare(
    SQL => "SELECT t.id FROM ticket t, ticket_state ts, ticket_state_type tst WHERE"
        . " t.ticket_state_id = ts.id AND ts.type_id = tst.id AND tst.name IN"
        . " ('new', 'open', 'pending reminder', 'pending auto')"
);

my @TicketIDs;
while ( my @Row = $DBObject->FetchrowArray() ) {
    push @TicketIDs, $Row[0];
}
exit(0) if !scalar @TicketIDs;

my $DynamicFieldConfigDirection = $DynamicFieldObject->DynamicFieldGet(
    Name => "TicketLastCustomerContactDirection",
);
exit(0) if !$DynamicFieldConfigDirection;

my $DynamicFieldConfigTime = $DynamicFieldObject->DynamicFieldGet(
    Name => "TicketLastCustomerContactTime",
);
exit(0) if !$DynamicFieldConfigTime;

# ticket loop
TICKETS:
for my $TicketID ( sort { $a <=> $b } @TicketIDs ) {

    my @ArticleIndex = $TicketObject->ArticleIndex( TicketID => $TicketID );

    next TICKETS if !scalar @ArticleIndex;

    # article loop
    ARTICLES:
    for my $ArticleID ( reverse sort { $a <=> $b } @ArticleIndex ) {

        my %Article = $TicketObject->ArticleGet( ArticleID => $ArticleID );

        next ARTICLES if !%Article;
        next ARTICLES if $Article{SenderType} !~ /^(customer|agent)/;
        next ARTICLES if $Article{ArticleType} !~ /(extern|phone|fax|sms)/;

        my $SystemTime = $TimeObject->TimeStamp2SystemTime(
            String => $Article{Created},
        );

        # update last customer update timestamp
        my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
            SystemTime => $SystemTime
        );

        my $Direction = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfigDirection,
            ObjectID           => $TicketID,
            Value              => $Article{SenderType},
            UserID             => 1,
        );

        my $Time = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfigTime,
            ObjectID           => $TicketID,
            Value              => $Article{Created},
            UserID             => 1,
        );

        last ARTICLES;
    }
}

exit(0);
