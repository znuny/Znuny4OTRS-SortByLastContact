# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Znuny4OTRS::SortByLastContact;

use strict;
use warnings;

use parent qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::System::ZnunyTime',
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

    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $TimeObject                = $Kernel::OM->Get('Kernel::System::ZnunyTime');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ArticleObject             = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my @TicketIDs = $TicketObject->TicketSearch(
        UserID    => 1,
        Result    => 'ARRAY',
        StateType => 'Open',    # (Open|Closed) tickets for all closed or open tickets.
    );

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

        my @Articles = $ArticleObject->ArticleList(
            TicketID => $TicketID,
        );

        my %ArticleSenderTypeList = $ArticleObject->ArticleSenderTypeList();

        next TICKETS if !scalar @Articles;

        # article loop
        ARTICLES:
        for my $Article ( reverse sort { $a->{ArticleID} <=> $b->{ArticleID} } @Articles ) {
            my $SenderType = $ArticleSenderTypeList{ $Article->{SenderTypeID} };

            next ARTICLES if $SenderType !~ /^(customer|agent)/;
            next ARTICLES if $Article->{IsVisibleForCustomer} eq 0;

            my $SystemTime = $TimeObject->TimeStamp2SystemTime(
                String => $Article->{CreateTime},
            );

            # update last customer update timestamp
            my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
                SystemTime => $SystemTime,
            );

            my $Direction = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigDirection,
                ObjectID           => $TicketID,
                Value              => $SenderType,
                UserID             => 1,
            );

            if ( !$Direction ) {
                $Self->PrintError("Can't update DynamicField TicketLastCustomerContactDirection.\n");
                return $Self->ExitCodeError();
            }

            my $Time = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigTime,
                ObjectID           => $TicketID,
                Value              => $Article->{CreateTime},
                UserID             => 1,
            );

            if ( !$Time ) {
                $Self->PrintError("Can't update DynamicField TicketLastCustomerContactDirection.\n");
                return $Self->ExitCodeError();
            }

            last ARTICLES;
        }

        # no GuardClause :)
    }

    $Self->Print("\n<green>Done.</green>\n");

    return $Self->ExitCodeOk();
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
