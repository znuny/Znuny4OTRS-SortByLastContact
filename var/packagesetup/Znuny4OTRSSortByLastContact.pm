# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::Znuny4OTRSSortByLastContact;

use strict;
use warnings;

use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DynamicField',
    'Kernel::System::SysConfig',
    'Kernel::System::Valid',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

BVDefaults.pm - code to execute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::BVDefaults');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # rebuild ZZZ* files
    $Kernel::OM->Get('Kernel::System::SysConfig')->WriteDefault();

    # define the ZZZ files
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {

        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if !-f $File;
            do $File;
            last PREFIX;
        }
    }

    # always discard the config object before package code is executed,
    # to make sure that the config object will be created newly, so that it
    # will use the recently written new config from the package
    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::Config'],
    );

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    $Self->_CreateDynamicFields();

    return 1;
}

sub _CreateDynamicFields {
    my ( $Self, %Param ) = @_;

    my $ValidObject        = $Kernel::OM->Get('Kernel::System::Valid');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $ValidID = $ValidObject->ValidLookup(
        Valid => 'valid',
    );

    # get all current dynamic fields
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
    }

    # get the last element from the order list and add 1
    my $NextOrderNumber = 1;
    if (@DynamicfieldOrderList) {
        $NextOrderNumber = $DynamicfieldOrderList[-1] + 1;
    }

    # create dynamic fields
    my $DynamicFieldConfigDirection = $DynamicFieldObject->DynamicFieldGet(
        Name => "TicketLastCustomerContactDirection",
    );

    my $DynamicFieldConfigTime = $DynamicFieldObject->DynamicFieldGet(
        Name => "TicketLastCustomerContactTime",
    );

    my $TicketLastCustomerContactTimeID = $DynamicFieldObject->DynamicFieldAdd(
        InternalField => 0,
        Name          => 'TicketLastCustomerContactTime',
        Label         => 'TicketLastCustomerContactTime',
        FieldOrder    => $NextOrderNumber,
        FieldType     => 'DateTime',
        ObjectType    => 'Ticket',
        Config        => {
            'DefaultValue'  => 0,
            'Link'          => '',
            'YearsInFuture' => 5,
            'YearsInPast'   => 5,
            'YearsPeriod'   => 0,
        },
        ValidID => $ValidID,
        UserID  => 1,
    );

    if ($TicketLastCustomerContactTimeID) {
        $NextOrderNumber++;
    }

    my $TicketLastCustomerContactDirection = $DynamicFieldObject->DynamicFieldAdd(
        InternalField => 0,
        Name          => 'TicketLastCustomerContactDirection',
        Label         => 'TicketLastCustomerContactDirection',
        FieldOrder    => $NextOrderNumber,
        FieldType     => 'Text',
        ObjectType    => 'Ticket',
        Config        => {
            'DefaultValue' => '',
            'Link'         => ''
        },
        ValidID => $ValidID,
        UserID  => 1,
    );

    if ($TicketLastCustomerContactDirection) {
        $NextOrderNumber++;
    }
    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the Znuny project (http://znuny.com/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
