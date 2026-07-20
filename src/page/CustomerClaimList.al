page 50129 "Customer Claim List"
{
    PageType = List;
    SourceTable = CustomerClaim;
    Caption = 'Customer Claims';
    CardPageId = "Customer Claim Card";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Général)
            {
                field("Claim No."; Rec."claim No.")
                {
                    ApplicationArea = All;
                }

                field("Date de création"; Rec.creationDate)
                {
                    ApplicationArea = All;
                }

                field(CustomerNo; Rec.customerNo)
                {
                    ApplicationArea = All;
                }

                field(VehicleNo; Rec.vehicleNo)
                {
                    ApplicationArea = All;
                }

                field(Immatriculation; Rec.registrationNumber)
                {
                    Caption = 'Immatriculation';
                    ApplicationArea = All;
                }

                field(Priorité; Rec.priority)
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}