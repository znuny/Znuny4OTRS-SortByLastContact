# --
# Kernel/System/Ticket/Event/TimeUpdate.pm - time update event module
# Copyright (C) 2001-2022 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# $origin: otrs - 8207d0f681adcdeb5c1b497ac547a1d9749838d5 - Kernel/System/Ticket/Event/TimeUpdate.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Ticket::Event::TimeUpdate;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(MainObject EncodeObject ConfigObject TicketObject LogObject TimeObject DBObject StateObject)
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

    my $FieldText = $Self->{ConfigObject}->Get('Znuny4OTRSSortByLastContact::FreeTextUsed');

    return 1 if !$FieldText;

    my $FieldTime = $Self->{ConfigObject}->Get('Znuny4OTRSSortByLastContact::FreeTimeUsed');

    return 1 if !$FieldTime;

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

    my $LastContactTime   = $Article{ 'TicketFreeTime' . $FieldTime } || '';
    my $LastSender        = $Article{ 'TicketFreeText' . $FieldText } || '';
    my $NewSender         = $Article{SenderType};
    my $StateType         = $Ticket{StateType};
    my $PreviousStateType = $PreviousState{TypeName} || '';

    return 1
        if $LastSender eq 'customer'
            && $NewSender eq 'customer'
            && $StateType eq 'open'
            && $PreviousStateType ne 'closed';

    # remember sender type
    $Self->{TicketObject}->TicketFreeTextSet(
        Counter  => $FieldText,
        Key      => 'Last Sender',
        Value    => $Article{SenderType},
        TicketID => $Param{TicketID},
        UserID   => 1,
    );

    # remember sender time stamp
    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $Self->{TimeObject}->SystemTime2Date(
        SystemTime => $Self->{TimeObject}->TimeStamp2SystemTime(
            String => $Article{Created},
        ),
    );
    $Self->{TicketObject}->TicketFreeTimeSet(
        Prefix                                   => 'TicketFreeTime',
        TicketID                                 => $Param{TicketID},
        Counter                                  => $FieldTime,
        UserID                                   => 1,
        'TicketFreeTime' . $FieldTime . 'Year'   => $Year,
        'TicketFreeTime' . $FieldTime . 'Month'  => $Month,
        'TicketFreeTime' . $FieldTime . 'Day'    => $Day,
        'TicketFreeTime' . $FieldTime . 'Hour'   => $Hour,
        'TicketFreeTime' . $FieldTime . 'Minute' => $Min,
        'TicketFreeTime' . $FieldTime . 'Second' => $Sec,
    );

    return 1;
}

1;
