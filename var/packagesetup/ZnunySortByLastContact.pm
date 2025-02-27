# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::ZnunySortByLastContact;    ## no critic

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::ZnunyHelper',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

var::packagesetup::ZnunySortByLastContact - code to execute during package installation

=head1 SYNOPSIS

All code to execute during package installation

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $CodeObject    = $Kernel::OM->Get('var::packagesetup::ZnunySortByLastContact');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

    my @DynamicFields = (
        {
            Name  => 'TicketLastCustomerContactTime',
            Label => "TicketLastCustomerContactTime",

            InternalField => 1,
            ObjectType    => 'Ticket',
            FieldType     => 'DateTime',
            Config        => {
                'DefaultValue'  => 0,
                'Link'          => '',
                'YearsInFuture' => 5,
                'YearsInPast'   => 5,
                'YearsPeriod'   => 0,
            },
        },
        {
            Name  => 'TicketLastCustomerContactDirection',
            Label => "TicketLastCustomerContactDirection",

            InternalField => 1,
            ObjectType    => 'Ticket',
            FieldType     => 'Dropdown',
            Config        => {
                PossibleValues => {
                    'agent'    => 'agent',
                    'customer' => 'customer'
                }
            },
        },
    );

    return if !$ZnunyHelperObject->_DynamicFieldsCreateIfNotExists(@DynamicFields);

    return 1;
}

=head2 CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

    my @DynamicFieldRemove = (
        'TicketLastCustomerContactTime',
        'TicketLastCustomerContactDirection'
    );

    return if !$ZnunyHelperObject->_DynamicFieldsDelete(@DynamicFieldRemove);

    return 1;
}

=head2 CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DBObject           = $Kernel::OM->Get('Kernel::System::DB');

    my @DynamicFieldList = ( 'TicketLastCustomerContactTime', 'TicketLastCustomerContactDirection' );

    # Upgrade dynamic fields to internal fields.
    # At the moment you can not update 'InternalField' via the DynamicField API.
    # So we have to do it manually via SQL.
    DYNAMICFIELD:
    for my $DynamicField (@DynamicFieldList) {
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $DynamicField,
        );
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # Set internal field.
        $DynamicFieldConfig->{InternalField} = 1;

        next DYNAMICFIELD if !$DBObject->Do(
            SQL  => 'UPDATE dynamic_field SET internal_field = ? WHERE id = ?',
            Bind => [
                \$DynamicFieldConfig->{InternalField}, \$DynamicFieldConfig->{ID},
            ],
        );
    }

    # Upgrade dynamic field type.
    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => 'TicketLastCustomerContactDirection'
    );
    return if !IsHashRefWithData($DynamicFieldConfig);

    my $DynamicFieldUpdated = $DynamicFieldObject->DynamicFieldUpdate(
        %{$DynamicFieldConfig},
        FieldType => 'Dropdown',
        Config    => {
            PossibleValues => {
                'agent'    => 'agent',
                'customer' => 'customer'
            }
        },
        UserID => 1,
    );

    return if !$DynamicFieldUpdated;

    return 1;
}

1;
