page 50111 StaVehicleList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = StaVehicle;
    Caption = 'Vehicles';

    CardPageId = StaVehicleCard;

    layout
    {
        area(Content)
        {

            repeater(Vehicles)
            {

                field("Numero véhicule"; Rec."NumVehicle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vehicle number.';
                }

                field("Make Code"; Rec."Make Code")
                {
                    ApplicationArea = All;
                    Caption = 'Make Code', Locked = true;
                    ToolTip = 'Specifies the make of the vehicle.';
                }

                field("Model Code"; Rec."Model Code")
                {
                    ApplicationArea = All;
                    Caption = 'Model Code', Locked = true;
                }

                field("Motorisation"; Rec."Motorisation")
                {
                    ApplicationArea = All;
                    Caption = 'Motorisation', Locked = true;
                }

                field("Customer No."; Rec."NumCustomer")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.', Locked = true;
                }
                field("Name"; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                }
            }
        }
    }


    actions
    {
        area(Navigation)
        {
            action(OpenCard)
            {
                Caption = 'Open Card';
                Image = EditLines;

                trigger OnAction()
                begin
                    Page.Run(Page::StaVehicleCard, Rec);
                end;
            }
        }

        area(Processing)
        {
            action(DeleteVehicle)
            {
                Caption = 'Delete';
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.Delete(true);
                end;
            }
        }
    }
    var
        CustomerName: Text[100];
        CustomerRec: Record StaCustomer;

    trigger OnAfterGetCurrRecord()
    begin
        if CustomerRec.Get(Rec."NumCustomer") then begin
            CustomerName := CustomerRec.FirstName + ' ' + CustomerRec.LastName;
        end
        else begin
            CustomerName := 'vide';
        end;
    end;

}
