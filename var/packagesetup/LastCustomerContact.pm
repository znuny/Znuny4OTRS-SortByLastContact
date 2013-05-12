# --
# LastCustomerContact.pm
# Copyright (C) 2013 Znuny GmbH, http://znuny.com/
# --

package var::packagesetup::LastCustomerContact;

use strict;
use warnings;

use Kernel::Config;
use Kernel::System::SysConfig;
use Kernel::System::Valid;
use Kernel::System::DynamicField;
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (
        qw( EncodeObject LogObject MainObject TimeObject DBObject ConfigObject )
        )
    {
        $Self->{$Object} = $Param{$Object} ||
            $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Missing parameter for $Object!"
            );
    }

    $Self->{ValidObject}        = Kernel::System::Valid->new( %{$Self} );
    $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new( %{$Self} );

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

    my $ValidID = $Self->{ValidObject}->ValidLookup(
        Valid => 'valid',
    );

    # get all current dynamic fields
    my $DynamicFieldList = $Self->{DynamicFieldObject}->DynamicFieldListGet(
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
    my $DynamicFieldConfigDirection = $Self->{DynamicFieldObject}->DynamicFieldGet(
        Name => "TicketLastCustomerContactDirection",
    );

    my $DynamicFieldConfigTime = $Self->{DynamicFieldObject}->DynamicFieldGet(
        Name => "TicketLastCustomerContactTime",
    );

    my $TicketLastCustomerContactTimeID = $Self->{DynamicFieldObject}->DynamicFieldAdd(
        Name       => 'TicketLastCustomerContactTime',
        Label      => 'TicketLastCustomerContactTime',
        FieldOrder => $NextOrderNumber,
        FieldType  => 'DateTime',
        ObjectType => 'Ticket',
        Config     => {},
        ValidID    => $ValidID,
        UserID     => 1,
    );

    if ($TicketLastCustomerContactTimeID) {
        $NextOrderNumber++;

    }


    my $TicketLastCustomerContactDirection = $Self->{DynamicFieldObject}->DynamicFieldAdd(
        Name       => 'TicketLastCustomerContactDirection',
        Label      => 'TicketLastCustomerContactDirection',
        FieldOrder => $NextOrderNumber,
        FieldType  => 'Text',
        ObjectType => 'Ticket',
        Config     => {},
        ValidID    => $ValidID,
        UserID     => 1,
    );

    if ($TicketLastCustomerContactDirection) {
        $NextOrderNumber++;
    }
    return 1;
}

1;
