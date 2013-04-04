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
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "_CreateDynamicFields started",
            );
    return 1;
}

sub _CreateDynamicFields {
    my ( $Self, %Param ) = @_;

            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "_CreateDynamicFields started",
            );

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
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "_CreateDynamicFields order number ",
            );
    # create dynamic fields
    my $DynamicFieldConfigDirection = $Self->{DynamicFieldObject}->DynamicFieldGet(
        Name => "TicketLastCustomerContactDirection",
    );

    my $DynamicFieldConfigTime = $Self->{DynamicFieldObject}->DynamicFieldGet(
        Name => "TicketLastCustomerContactTime",
    );

    #Check if field exists
    if ( !$DynamicFieldConfigTime ) {
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
        else {
            $Self->{LogObject}->Log(
                Priority => 'info',
                Message  => "Error while creating field TicketLastCustomerContactTime. "
            );
            return 0;
        }
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'info',
            Message  => "Field TicketLastCustomerContactTime already exists. "
        );
    }

    if ( !$DynamicFieldConfigTime ) {
        my $TicketLastCustomerContactTimeID = $Self->{DynamicFieldObject}->DynamicFieldAdd(
            Name       => 'TicketLastCustomerContactDirection',
            Label      => 'TicketLastCustomerContactDirection',
            FieldOrder => $NextOrderNumber,
            FieldType  => 'Text',
            ObjectType => 'Ticket',
            Config     => {},
            ValidID    => $ValidID,
            UserID     => 1,
        );
        if ($TicketLastCustomerContactTimeID) {
            $NextOrderNumber++;

        }
        else {
            $Self->{LogObject}->Log(
                Priority => 'info',
                Message  => "Error while creating field TicketLastCustomerContactDirection. "
            );
            return 0;
        }
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'info',
            Message  => "Field TicketLastCustomerContactDirection already exists. "
        );
    }

    return 1;
}

1;
