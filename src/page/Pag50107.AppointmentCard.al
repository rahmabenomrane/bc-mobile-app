page 50107 "Appointment Card"
{

    PageType = Card;
    SourceTable = Appointment;
    Caption = 'Rendez-vous';
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Informations';

                field("Appointment No."; Rec."Appointment No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = false;
                }

                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
            }

            group("Appointment Details")
            {
                Caption = 'Appointment Details';

                // field("Agency Code"; Rec."Agency Code")
                // {
                //     ApplicationArea = All;
                // }
                field("Agency Name"; AgencyName)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }

                field("Agency Address"; AgencyAddress)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }

                field("Service"; Rec."Service Code")
                {
                    ApplicationArea = All;
                }

                field("vehicle registration Number"; Rec."NumVehicle")
                {
                    ApplicationArea = All;
                }
                field("Brand"; MakeCode)
                {
                    ApplicationArea = All;
                }
                field("Model"; ModelCode)
                {
                    ApplicationArea = All;
                }
                field("Client"; ClientName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Client Phone"; ClientPhone)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group("Schedule")
            {
                Caption = 'Schedule';

                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                }

                field("Time"; Rec."Time")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Complete)
            {
                Caption = 'Complete';
                Image = Approve;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Completed;
                    Rec.Modify();
                end;
            }

            action(Cancel)
            {
                Caption = 'Cancel';
                Image = Cancel;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Canceled;
                    Rec.Modify();
                end;
            }

        }

    }
    trigger OnAfterGetCurrRecord()
    begin
        //AGENCE
        if AgencyRec.Get(Rec."Agency Code") then begin
            AgencyName := AgencyRec.Name;
            AgencyAddress := AgencyRec.Address;
        end
        else begin
            AgencyName := '';
            AgencyAddress := '';
        end;
        //CLIENT
        if VehicleRec.Get(Rec.NumVehicle) then begin
            if ClientRec.Get(VehicleRec.NumCustomer) then begin
                ClientName := ClientRec.FirstName + ' ' + ClientRec.LastName;
                ClientPhone := ClientRec.Phone;
            end
            else begin
                ClientName := '';
                ClientPhone := '';
            end;
        end;
        //VEHICLE
        if VehicleRec.Get(Rec.NumVehicle) then begin
            MakeCode := VehicleRec."Make Code";
            ModelCode := VehicleRec."Model Code";
        end
        else begin
            MakeCode := '';
            ModelCode := '';
        end;
    end;

    var
        AgencyRec: Record Agency;
        VehicleRec: Record StaVehicle;
        ModelCode: Text[50];
        AgencyName: Text[100];
        AgencyAddress: Text[150];
        MakeCode: Text[50];
        ClientRec: Record StaCustomer;
        ClientName: Text[100];
        ClientPhone: Text[20];
}