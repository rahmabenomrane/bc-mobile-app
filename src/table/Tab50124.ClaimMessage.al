table 50124 ClaimMessage
{
    Caption = 'Claim Message';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Claim No."; Code[20])
        {
            Caption = 'Claim No.';
            TableRelation = CustomerClaim."claim No.";
        }

        field(3; Message; Text[1000])
        {
            Caption = 'Message';
        }

        field(4; SenderType; Enum "Claim Message Sender")
        {
            Caption = 'Expéditeur';
        }

        field(5; SenderName; Text[100])
        {
            Caption = 'Nom de l''expéditeur';
        }

        field(6; MessageDateTime; DateTime)
        {
            Caption = 'Date et heure';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(ClaimKey; "Claim No.", MessageDateTime)
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("Claim No.");
        TestField(Message);

        if MessageDateTime = 0DT then
            MessageDateTime := CurrentDateTime;
    end;
}