page 50123 "CustomerClaim API"
{
    PageType = API;
    APIVersion = 'v1.0';
    SourceTable = CustomerClaim;
    Caption = 'Customer Claim API';
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    EntityName = 'Claim';
    EntitySetName = 'Claims';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Claims)
            {
                field("claimNumber"; Rec."claim No.")
                {
                    Caption = 'Claim Number';
                }
                field(creationDate; Rec.creationDate)
                {
                    Caption = 'Creation Date';
                }
                field(customerNo; Rec.customerNo)
                {
                    Caption = 'Customer Number';
                }
                field(description; Rec.description)
                {
                    Caption = 'Description';
                }
                field(status; Rec.status)
                {
                    Caption = 'Status';
                }
                field(priority; Rec.priority)
                {
                    Caption = 'Priority';
                }
                field(vehicleNo; Rec.vehicleNo)
                {
                    Caption = 'Vehicle Number';
                }
                field(registrationNumber; Rec.registrationNumber)
                {
                    Caption = 'Registration Number';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateStatus)
            {
                Caption = 'Update Claim Status';

                trigger OnAction()
                var
                    Claim: Record CustomerClaim;
                    NewStatus: Enum "Claim Status";
                begin
                    if not Claim.Get(Rec."claim No.") then
                        Error('Claim not found');

                    Claim.status := NewStatus;
                    Claim.Modify(true);
                end;
            }
        }
    }
}