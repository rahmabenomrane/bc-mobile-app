table 50100 Agency
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20]) { }
        field(2; Name; Text[100]) { }
        field(3; Address; Text[150]) { }
        field(4; PhoneNo; Text[20]) { }
        field(5; Email; Text[100])
        {
            trigger OnValidate()
            begin
                if (Email <> '') and (StrPos(Email, '@') = 0) then
                    Error('Invalid email format.');
            end;
        }
        field(6; Capacity; Integer)
        {
            trigger OnValidate()
            begin
                if Capacity <= 0 then
                    Error('Capacity must be greater than 0.');
            end;
        }
        field(7; "Office hours"; Text[100]) { }
        field(8; Latitude; Decimal)
        {
            MinValue = -90;
            MaxValue = 90;
        }
        field(9; Longitude; Decimal)
        {
            MinValue = -180;
            MaxValue = 180;
        }
        field(10; "Agency Type"; Enum AgencyType) { }

        field(11; "Base Calendar Code"; Code[10])
        {
            Caption = 'Calendrier de base';
            TableRelation = "Base Calendar".Code;

            trigger OnValidate()
            begin
                if "Base Calendar Code" = '' then exit;
                if not BaseCalendarExists("Base Calendar Code") then
                    Error('Le calendrier %1 n''existe pas. Utilisez l''action "Gérer le calendrier" pour le créer.', "Base Calendar Code");
            end;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    local procedure BaseCalendarExists(CalCode: Code[10]): Boolean
    var
        BaseCalendar: Record "Base Calendar";
    begin
        exit(BaseCalendar.Get(CalCode));
    end;

    trigger OnDelete()
    var
        Appointment: Record "Appointment";
        BaseCalendar: Record "Base Calendar";
    begin
        Appointment.SetRange("Agency Code", Code);
        if not Appointment.IsEmpty() then
            Error('You cannot delete this agency because it has appointments.');

        // Optionnel : nettoyer le calendrier associé
        if "Base Calendar Code" <> '' then
            if BaseCalendar.Get("Base Calendar Code") then
                BaseCalendar.Delete(true);
    end;

    trigger OnInsert()
    var
        Agency: Record Agency;
        LastNo: Integer;
    begin
        if Code <> '' then
            exit;

        if Agency.FindLast() then begin
            Evaluate(LastNo, CopyStr(Agency.Code, 3));
            LastNo += 1;
        end else
            LastNo := 1;

        Code := 'AG' + Format(LastNo, 4, '<Integer,4><Filler Character,0>');
    end;
}