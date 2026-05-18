table 50120 "STA Customer Session"
{
    DataClassification = CustomerContent;

    fields
    {

        field(1; Token; Text[200])
        {
            Caption = 'Token';
        }
        field(2; CustomerId; Guid)
        {
            Caption = 'Customer Id';
        }
        field(3; ExpiresAt; DateTime)
        {
            Caption = 'Expires At';
        }
        field(4; IsActive; Boolean)
        {
            Caption = 'Is Active';
        }
        field(8; CustomerNumber; Code[20])
        {
            Caption = 'Customer Number';
        }
        field(5; CreatedAt; DateTime) { Caption = 'Created At'; }
        field(7; Phone; Text[50]) { }
        field(6; Password; Text[100]) { }
    }

    keys
    {
        key(PK; Token) { Clustered = true; }
        key(K2; CustomerId) { }
    }
}