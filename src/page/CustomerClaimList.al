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
                    Caption='Date de création';
                }

                field(CustomerNo; Rec.customerNo)
                {
                    ApplicationArea = All;
                    Caption='Numéro du client';
                }

                field(VehicleNo; Rec.vehicleNo)
                {
                    ApplicationArea = All;
                    Caption='Numéro du véhicule';
                }

                field(Immatriculation; Rec.registrationNumber)
                {
                    Caption = 'Immatriculation';
                    ApplicationArea = All;
                }

                field(Priorité; Rec.priority)
                {
                    ApplicationArea = All;
                    Caption='Priorité';
                }

                field(Status; Rec.status)
                {
                    ApplicationArea = All;
                    Caption='Statut';
                }
            }
        }
    }
}