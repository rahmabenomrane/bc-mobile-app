page 50124 CustomerList
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = StaCustomer;
    Caption = 'Clients';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(FirstName; Rec.FirstName)
                {
                    ApplicationArea = All;
                }
                field(LastName; Rec.LastName)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                }
                field(civility; Rec.civility)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}