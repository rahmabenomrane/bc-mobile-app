enum 50120 "Claim Status"
{
    Caption = 'Claim Status';
    Extensible = true;

    value(0; "In Progress")
    {
        Caption = 'In Progress';
    }

    value(1; "Resolved")
    {
        Caption = 'Resolved';
    }

    value(2; "Closed")
    {
        Caption = 'Closed';
    }

    value(3; "Cancelled")
    {
        Caption = 'Cancelled';
    }
}