# --
# Copyright (C) 2001-2022 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# Get needed objects.
my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# Get helper object.
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase  => 1,
        UseTmpArticleDir => 1,
    },
);

my @Tests = (
    {
        Name => 'TicketCreate - without Article',
        Data => {

        },
        ExpectedResult => {
            Ticket => {
                DynamicField_TicketLastCustomerContactTime      => undef,
                DynamicField_TicketLastCustomerContactDirection => undef,
            },
        },
    },
    {
        Name => 'TicketCreate - SenderType: system - IsVisibleForCustomer: 1',
        Data => {
            Article => {
                SenderType           => 'system',
                IsVisibleForCustomer => 1,
            },
        },
        ExpectedResult => {
            Ticket => {
                DynamicField_TicketLastCustomerContactTime      => undef,
                DynamicField_TicketLastCustomerContactDirection => undef,
            },
        },
    },

    {
        Name => 'TicketCreate - SenderType: customer - IsVisibleForCustomer: 0',
        Data => {
            Article => {
                SenderType           => 'customer',
                IsVisibleForCustomer => 0,
            },
        },
        ExpectedResult => {
            Ticket => {
                DynamicField_TicketLastCustomerContactTime      => undef,
                DynamicField_TicketLastCustomerContactDirection => undef,
            },
        },
    },

    {
        Name => 'TicketCreate - SenderType: agent - IsVisibleForCustomer: 0',
        Data => {
            Article => {
                SenderType           => 'customer',
                IsVisibleForCustomer => 0,
            },
        },
        ExpectedResult => {
            Ticket => {
                DynamicField_TicketLastCustomerContactTime      => undef,
                DynamicField_TicketLastCustomerContactDirection => undef,
            },
        },
    },

    {
        Name => 'TicketCreate - SenderType: agent - IsVisibleForCustomer: 1',
        Data => {
            Article => {
                SenderType           => 'agent',
                IsVisibleForCustomer => 1,
            },
        },
        ExpectedResult => {
            Ticket => {
                DynamicField_TicketLastCustomerContactTime      => '2016-04-16 16:04:16',
                DynamicField_TicketLastCustomerContactDirection => 'agent',
            },
        },
    },

    {
        Name => 'TicketCreate - SenderType: customer - IsVisibleForCustomer: 1',
        Data => {
            Article => {
                SenderType           => 'customer',
                IsVisibleForCustomer => 1,
            },
        },
        ExpectedResult => {
            Ticket => {
                DynamicField_TicketLastCustomerContactTime      => '2016-04-16 16:04:16',
                DynamicField_TicketLastCustomerContactDirection => 'customer',
            },
        },
    },
);

for my $Test (@Tests) {

    $Self->True(
        $Test->{Name},
        "Start Test: $Test->{Name}",
    );

    $HelperObject->FixedTimeSetByDate(
        Year   => 2016,
        Month  => 4,
        Day    => 16,
        Hour   => 16,
        Minute => 4,
        Second => 16,
    );

    my $TicketID = $HelperObject->TicketCreate(
        Title => $Test->{Name},
    );

    if ( $Test->{Data}->{Article} ) {

        my $ArticleID = $HelperObject->ArticleCreate(
            %{ $Test->{Data}->{Article} },
            TicketID => $TicketID,
        );
    }

    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::System::Ticket'],
    );

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $TicketID,
        DynamicFields => 1,
        UserID        => 1,
    );

    $Self->True(
        %Ticket ? 1 : 0,
        $Test->{Name} . " - Ticket with ID must exist.",
    );

    # Check all Ticket-Attributes
    for my $Attribute ( sort keys %{ $Test->{ExpectedResult}->{Ticket} } ) {

        $Self->Is(
            $Ticket{$Attribute},
            $Test->{ExpectedResult}->{Ticket}->{$Attribute},
            "Checked $Attribute successful.",
        );

    }

}

1;
