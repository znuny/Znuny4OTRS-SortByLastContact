# --
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Znuny::SortByLastContact;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
    'Kernel::System::Time',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Updates all tickets with last customer contact.');
    $Self->AddOption(
        Name        => 'list',
        Description => "Lists all ticketnumbers.",
        Required    => 0,
        HasValue    => 0,
        ValueRegex  => qr/.*/smx,
    );

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Updating all tickets with last customer contact time...</yellow>\n\n");

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

    if ( !scalar @TicketIDs ) {
        $Self->PrintError("Can't update. Need TicketIDs.\n");
        return $Self->ExitCodeError();
    }

    my $DynamicFieldConfigDirection = $DynamicFieldObject->DynamicFieldGet(
        Name => "TicketLastCustomerContactDirection",
    );

    if ( !$DynamicFieldConfigDirection ) {
        $Self->PrintError("Can't update. Need DynamicFieldConfigDirection.\n");
        return $Self->ExitCodeError();
    }

    my $DynamicFieldConfigTime = $DynamicFieldObject->DynamicFieldGet(
        Name => "TicketLastCustomerContactTime",
    );

    if ( !$DynamicFieldConfigTime ) {
        $Self->PrintError("Can't update. Need DynamicFieldConfigTime.\n");
        return $Self->ExitCodeError();
    }

    # ticket loop
    TICKETS:
    for my $TicketID ( sort { $a <=> $b } @TicketIDs ) {
        if ( $Self->GetOption('list') ) {
            $Self->Print("<yellow>Updating TicketID $TicketID.</yellow>\n");
        }
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
                SystemTime => $SystemTime,
            );

            my $Direction = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigDirection,
                ObjectID           => $TicketID,
                Value              => $Article{SenderType},
                UserID             => 1,
            );

            if ( !$Direction ) {
                $Self->PrintError("Can't update DynamicField TicketLastCustomerContactDirection.\n");
                return $Self->ExitCodeError();
            }

            my $Time = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigTime,
                ObjectID           => $TicketID,
                Value              => $Article{Created},
                UserID             => 1,
            );

            if ( !$Time ) {
                $Self->PrintError("Can't update DynamicField TicketLastCustomerContactDirection.\n");
                return $Self->ExitCodeError();
            }

            last ARTICLES;
        }
    }

    $Self->Print("\n<green>Done.</green>\n");

    return $Self->ExitCodeOk();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
