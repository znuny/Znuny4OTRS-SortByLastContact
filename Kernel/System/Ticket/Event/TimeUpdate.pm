# --
# Copyright (C) 2012-2018 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::TimeUpdate;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::State',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::System::ZnunyTime',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LogObject                 = $Kernel::OM->Get('Kernel::System::Log');
    my $StateObject               = $Kernel::OM->Get('Kernel::System::State');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $TimeObject                = $Kernel::OM->Get('Kernel::System::ZnunyTime');
    my $ArticleObject             = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Data Event Config)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    return 1 if !$Param{Data}->{TicketID};
    return 1 if $Param{Event} ne 'ArticleCreate';

    # get last article
    my @Articles = $ArticleObject->ArticleList(
        TicketID => $Param{Data}->{TicketID},
        OnlyLast => 1,
    );

    my %ArticleSenderTypeList = $ArticleObject->ArticleSenderTypeList();
    my $SenderType            = $ArticleSenderTypeList{ $Articles[0]->{SenderTypeID} };

    return 1 if !scalar @Articles;
    return 1 if $Articles[0]->{IsVisibleForCustomer} eq 0;
    return 1 if $SenderType !~ /^(customer|agent)/;

    # remember sender type
    my $DynamicFieldConfigDirection = $DynamicFieldObject->DynamicFieldGet(
        Name => "TicketLastCustomerContactDirection",
    );
    return 1 if !$DynamicFieldConfigDirection;

    my $DynamicFieldConfigTime = $DynamicFieldObject->DynamicFieldGet(
        Name => "TicketLastCustomerContactTime",
    );
    return 1 if !$DynamicFieldConfigTime;

    # get the current ticket
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{Data}->{TicketID},
        UserID   => 1,
    );

    return if !%Ticket;

    # get the full ticket history of the current ticket
    my @TicketHistory = $TicketObject->HistoryGet(
        TicketID => $Param{Data}->{TicketID},
        UserID   => 1,
    );

    return if !@TicketHistory;

    # get only the StateUpdate entries
    my @UpdateHistory;
    ITEM:
    for my $Item (@TicketHistory) {

        next ITEM if !$Item;
        next ITEM if ref $Item ne 'HASH';

        next ITEM if $Item->{HistoryType} ne 'StateUpdate';

        push @UpdateHistory, $Item;
    }

    # get the previous history entry to get the date values
    # to find out the previous ticketstate in the next step
    my %PreviousState;
    if (
        scalar @UpdateHistory >= 2
        && $SenderType eq 'customer'
        )
    {
        # extract previous history entry
        my %PreviousHistoryEntry = %{ $UpdateHistory[-2] };

        # get the state of the previous history entry
        %PreviousState = $StateObject->StateGet(
            ID => $PreviousHistoryEntry{StateID},
        );
    }

    my $LastContactTime   = $Ticket{'TicketLastCustomerContactTime'}      || '';
    my $LastSender        = $Ticket{'TicketLastCustomerContactDirection'} || '';
    my $PreviousStateType = $PreviousState{TypeName}                      || '';
    my $NewSender         = $SenderType;
    my $StateType         = $Ticket{StateType};

    if (
        $LastSender eq 'customer'
        && $NewSender eq 'customer'
        && $StateType eq 'open'
        && $PreviousStateType ne 'closed'
        )
    {
        return 1
    }

    my $AricleCreatedSystemTime = $TimeObject->TimeStamp2SystemTime(
        String => $Articles[0]->{CreateTime},
    );

    # remember sender time stamp
    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
        SystemTime => $AricleCreatedSystemTime,
    );

    my $Direction = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfigDirection,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => $SenderType,
        UserID             => 1,
    );

    my $Time = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfigTime,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => $Articles[0]->{CreateTime},
        UserID             => 1,
    );

    return 1;
}

1;
