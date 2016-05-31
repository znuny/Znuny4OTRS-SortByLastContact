# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
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
    'Kernel::System::Time',
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
    my $TimeObject                = $Kernel::OM->Get('Kernel::System::Time');

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

    # get article index
    my @ArticleIndex = $TicketObject->ArticleIndex(
        TicketID => $Param{Data}->{TicketID},
    );

    return 1 if !scalar @ArticleIndex;

    # get last article
    my %Article = $TicketObject->ArticleGet(
        ArticleID => $ArticleIndex[-1],
    );

    return 1 if !%Article;
    return 1 if $Article{SenderType} !~ /^(customer|agent)/;
    return 1 if $Article{ArticleType} !~ /(extern|phone|fax|sms)/;

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
        && $Article{SenderType} eq 'customer'
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
    my $NewSender         = $Article{SenderType};
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
        String => $Article{Created},
    );

    # remember sender time stamp
    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
        SystemTime => $AricleCreatedSystemTime,
    );

    my $Direction = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfigDirection,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => $Article{SenderType},
        UserID             => 1,
    );

    my $Time = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfigTime,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => $Article{Created},
        UserID             => 1,
    );

    return 1;
}

1;
