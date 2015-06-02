#!/usr/bin/perl
# --
# bin/znuny.UpdateLastCustomerContact.pl - update all tickets with last customer contact
# Copyright (C) 2012-2015 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
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

        # update last customer update timestamp
        my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
            SystemTime => $TimeObject->TimeStamp2SystemTime(
                String => $Article{Created},
            ),
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
