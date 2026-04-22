table 50106 Appointment
{
    Caption = 'Appointment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Appointment No."; Code[20])
        {
            Caption = 'Appointment No.';
        }

        field(3; "Agency Code"; Code[20])
        {
            Caption = 'Agency Code';
            TableRelation = Agency.Code;
        }

        field(4; "Service Code"; Code[20])
        {
            Caption = 'Service Code';
            TableRelation = Service.ServiceCode;
        }

        field(9; "Service Description"; Text[100])
        {
            Caption = 'Service Description';
            TableRelation = Service.Description;
        }
        field(5; "Date"; Date)
        {
            Caption = 'Date';
        }

        field(6; "Time"; Time)
        {
            Caption = 'Time';
        }

        field(7; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = Scheduled,Canceled,Completed;
            OptionCaption = 'Scheduled,Canceled,Completed';
        }
        field(8; "NumVehicle"; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = StaVehicle."NumVehicle";
        }
    }

    keys
    {
        key(PK; "Appointment No.")
        {
            Clustered = true;
        }
    }
}