# --
# Kernel/System/Ticket/Event/TimeUpdate.pm - time update event module
# Copyright (C) 2013 Znuny GmbH, http://znuny.com/
# --


package Kernel::System::Ticket::Event::TimeUpdate;

use strict;
use warnings;
use Kernel::System::DynamicField::Backend;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(MainObject EncodeObject DynamicFieldObject DynamicFieldBackendObject TicketObject LogObject TimeObject DBObject ConfigObject)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID Event Config)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    return 1 if $Param{Event} ne 'ArticleCreate';

    # get article index
    my @ArticleIndex = $Self->{TicketObject}->ArticleIndex(
        TicketID => $Param{TicketID},
    );

    return 1 if !@ArticleIndex;

    # get last article
    my %Article = $Self->{TicketObject}->ArticleGet(
        ArticleID => $ArticleIndex[-1],
    );

    return 1 if !%Article;
    return 1 if $Article{SenderType} !~ /^(customer|agent)/;
    return 1 if $Article{ArticleType} !~ /(extern|phone|fax|sms)/;

    # remember sender type
    my $DynamicFieldConfigDirection = $Self->{DynamicFieldObject}->DynamicFieldGet(
        Name => "TicketLastCustomerContactDirection",
    );
    return 1 if !$DynamicFieldConfigDirection;

    my $DynamicFieldConfigTime = $Self->{DynamicFieldObject}->DynamicFieldGet(
        Name => "TicketLastCustomerContactTime",
    );
    return 1 if !$DynamicFieldConfigTime;
    
    # get the current ticket
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $Param{TicketID},
        UserID   => 1,
    );

    return if !%Ticket;

    # get the full ticket history of the current ticket
    my @TicketHistory = $Self->{TicketObject}->HistoryGet(
        TicketID => $Param{TicketID},
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

    # get the previous history entry to get the date values to find out the previous ticketstate in
    # the next step
    my %PreviousState;
    if ( scalar @UpdateHistory >= 2 && $Article{SenderType} eq 'customer' ) {

        # extract previous history entry
        my %PreviousHistoryEntry = %{ $UpdateHistory[-2] };

        # get the state of the previous history entry
        %PreviousState = $Self->{StateObject}->StateGet(
            ID => $PreviousHistoryEntry{StateID},
        );
    }

    my $LastContactTime   = $Ticket{ 'TicketLastCustomerContactTime' } || '';
    my $LastSender        = $Ticket{ 'TicketLastCustomerContactDirection' } || '';
    my $NewSender         = $Article{SenderType};
    my $StateType         = $Ticket{StateType};
    my $PreviousStateType = $PreviousState{TypeName}                  || '';

    return 1
        if $LastSender eq 'customer'
        && $NewSender  eq 'customer'
        && $StateType  eq 'open'
        && $PreviousStateType ne 'closed';

    # remember sender time stamp
    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $Self->{TimeObject}->SystemTime2Date(
        SystemTime => $Self->{TimeObject}->TimeStamp2SystemTime(
            String => $Article{Created},
        ),
    );

    my $Direction = $Self->{DynamicFieldBackendObject}->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfigDirection,
        ObjectID           => $Param{TicketID},
        Value              => $Article{SenderType},
        UserID             => 1,
    );

    my $Time = $Self->{DynamicFieldBackendObject}->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfigTime,
        ObjectID           => $Param{TicketID},
        Value              => $Article{Created},
        UserID             => 1,
    );

    return 1;
}

1;
