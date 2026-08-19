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
                    Caption = 'Client Num', Locked = true;
                }
                field("Mileage"; Rec."Mileage")
                {
                    ApplicationArea = All;
                    Caption = 'Kilométrage';
                }
                field("Name"; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Client';
                }
                field("Registration No."; Rec."RegistrationNumber")
                {
                    ApplicationArea = All;
                    Caption = 'Immatriculation', Locked = true;
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
                var
                    Vehicle: Record Vehicle;
                begin

                    Vehicle.Reset();
                    Vehicle.SetRange("Registration No.", Rec."RegistrationNumber");

                    if Vehicle.FindFirst() then begin

                        Page.Run(Page::"Vehicle Card", Vehicle);
                        exit;
                    end;


                    Clear(Vehicle);
                    Vehicle.Init();
                    Vehicle.Validate("Registration No.", Rec."RegistrationNumber");
                    Vehicle.Validate("Make Code", Rec."Make Code");
                    Vehicle.Validate("Model Code", Rec."Model Code");

                    Page.Run(Page::"Vehicle Card", Vehicle);
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
            action(OpenVehicleCard)
            {
                Caption = 'Finaliser la création du véhicule';
                Image = New;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Vehicle: Record Vehicle;
                begin
                    Vehicle.Reset();
                    Vehicle.SetRange("Registration No.", Rec."RegistrationNumber");

                    if Vehicle.FindFirst() then begin
                        Page.Run(Page::"Vehicle Card", Vehicle);
                        exit;
                    end;

                    Clear(Vehicle);

                    Vehicle.Init();
                    Vehicle."Registration No." := Rec."RegistrationNumber";
                    Vehicle."Make Code" := Rec."Make Code";
                    Vehicle."Model Code" := Rec."Model Code";

                    Page.Run(Page::"Vehicle Card", Vehicle);
                end;
            }
        }

    }
    var
        CustomerName: Text[100];
        CustomerRec: Record StaCustomer;

    trigger OnAfterGetCurrRecord()
    begin
        if CustomerRec.Get(Rec."NumCustomer") then
            CustomerName := CustomerRec.Name
        else
            CustomerName := 'vide';
    end;
}
