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
        field(12; "Agency Name"; Code[20])
        {
            Caption = 'Agency Name';
            TableRelation = Agency.Name;
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

        field(5; Date; Date)
        {
            trigger OnValidate()
            var
                Agency: Record Agency;
                BaseCalendar: Record "Base Calendar";
                CustCalendarChange: Record "Customized Calendar Change";
                CalendarMgt: Codeunit "Calendar Management";
            begin
                if "Agency Code" = '' then exit;
                if not Agency.Get("Agency Code") then exit;
                if Agency."Base Calendar Code" = '' then exit;
                if not BaseCalendar.Get(Agency."Base Calendar Code") then exit;

                CalendarMgt.SetSource(BaseCalendar, CustCalendarChange);

                if CalendarMgt.IsNonworkingDay(Date, CustCalendarChange) then
                    Error('Le %1 est un jour chômé pour l''agence %2. Merci de choisir une autre date.', Date, Agency.Code);
            end;
        }

        field(6; "StartTime"; Time)
        {
            Caption = 'StartTime';
        }
        field(11; "EndTime"; Time)
        {
            Caption = 'EndTime';
        }

        field(7; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,confirmed,Cancelled;
            OptionCaption = 'Pending,confirmed,Cancelled';
        }
        field(8; "NumVehicle"; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = StaVehicle.NumVehicle;
        }
        field(13; "registrationNumber"; Code[20])
        {
            Caption = 'Immatriculation';
            TableRelation = StaVehicle.RegistrationNumber;
        }
        field(10; "CarLift Code"; Code[20])
        {
            TableRelation = "CarLift";
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