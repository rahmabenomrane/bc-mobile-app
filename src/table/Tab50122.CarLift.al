table 50122 "CarLift"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
        }

        field(2; "Description"; Text[100])
        {
        }

        field(3; "Agency Code"; Code[20])
        {
            TableRelation = Agency.Code;
        }

        field(4; "Daily Capacity"; Integer)
        {
            trigger OnValidate()
            var
                AgencyRec: Record Agency;
                CarLiftRec: Record CarLift;
                TotalCapacity: Integer;
            begin
                if "Daily Capacity" < 0 then
                    Error('La capacité quotidienne ne peut pas être négative.');

                if "Agency Code" = '' then
                    exit;

                if not AgencyRec.Get("Agency Code") then
                    exit;

                TotalCapacity := 0;

                CarLiftRec.Reset();
                CarLiftRec.SetRange("Agency Code", "Agency Code");

                if CarLiftRec.FindSet() then
                    repeat
                        // Ne pas recompter le pont courant
                        if CarLiftRec.Code <> Code then
                            TotalCapacity += CarLiftRec."Daily Capacity";
                    until CarLiftRec.Next() = 0;

                TotalCapacity += "Daily Capacity";

                if TotalCapacity > AgencyRec.Capacity then
                    Error(
                        'La capacité totale des ponts (%1 h) ne peut pas dépasser la capacité de l''agence (%2 h).',
                        TotalCapacity,
                        AgencyRec.Capacity
                    );
            end;

        }

        field(5; "Active"; Boolean)
        {
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if "Agency Code" = '' then
            Error('Agency Code must not be empty');
    end;

}