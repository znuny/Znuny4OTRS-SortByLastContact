#!/usr/bin/perl -w
# --
# updatelastcustomercontact.pl - update all tickets with last customer contact
# Copyright (C) 2013 Znuny GmbH, http://znuny.com/
# --

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
use Kernel::System::DynamicField;

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
$CommonObject{DynamicFieldObject} = Kernel::System::DynamicField->new( %CommonObject );

# get all open tickets
my $SQL = "SELECT t.id FROM ticket t, ticket_state ts, ticket_state_type tst WHERE " .
    " t.ticket_state_id = ts.id AND ts.type_id = tst.id AND tst.name IN ('new', 'open', 'pending reminder', 'pending auto') ";
$CommonObject{DBObject}->Prepare( SQL => $SQL );

my @TicketIDs;
while ( my @Row = $CommonObject{DBObject}->FetchrowArray() ) {
    push @TicketIDs, $Row[0];
}
exit(0) if !@TicketIDs;

#my $FieldText = $CommonObject{ConfigObject}->Get('Znuny4OTRSSortByLastContact::FreeTextUsed');
#exit(0) if !$FieldText;

#my $Field = $CommonObject{ConfigObject}->Get('Znuny4OTRSSortByLastContact::FreeTimeUsed');
#exit(0) if !$Field;

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

        my $DynamicFieldConfigDirection = $CommonObject{DynamicFieldObject}->DynamicFieldGet(
            Name => "TicketLastCustomerContactDirection",
        );        

        my $DynamicFieldConfigTime = $CommonObject{DynamicFieldObject}->DynamicFieldGet(
            Name => "TicketLastCustomerContactTime",
        );

        my $Direction = $CommonObject{DynamicFieldBackendObject}->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfigDirection,
            ObjectID           => $TicketID,
            Value              => $Article{SenderType},
            UserID             => 1,
        );        

        my $Time = $CommonObject{DynamicFieldBackendObject}->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfigTime,
            ObjectID           => $TicketID,
            Value              => $Article{Created},
            UserID             => 1,
        );

        last ARTICLES;
    }
}

exit(0);
