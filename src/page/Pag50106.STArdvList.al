page 50106 "STA rdv List"
{
    PageType = List;
    SourceTable = Appointment;
    Caption = 'Rendez-vous';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Appointment Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Appointment No."; Rec."Appointment No.")
                {
                    ApplicationArea = All;
                }
                field("Agence"; AgencyName)
                {
                    ApplicationArea = All;
                }
                field("Service"; ServiceName)
                {
                    ApplicationArea = All;
                }
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                }
                field("Heure de début"; Rec."StartTime")
                {
                    Caption = 'Heure de début';
                    ApplicationArea = All;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                }
                field("Client"; ClientName)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(MarkCompleted)
    //         {
    //             Caption = 'Mark as Completed';
    //             Image = Approve;
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             begin
    //                 Rec.Status := Rec.Status::Completed;
    //                 Rec.Modify();
    //             end;
    //         }

    //         action(CancelAppointment)
    //         {
    //             Caption = 'Cancel Appointment';
    //             Image = Cancel;
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             begin
    //                 Rec.Status := Rec.Status::Canceled;
    //                 Rec.Modify();
    //             end;
    //         }
    //     }
    // }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Pending:
                StatusStyle := 'Ambiguous';
            Rec.Status::confirmed:
                StatusStyle := 'Favorable';
            Rec.Status::Cancelled:
                StatusStyle := 'Unfavorable';
        end;
        if AgencyRec.Get(Rec."Agency Code") then begin
            AgencyName := AgencyRec.Name;
        end else begin
            AgencyName := '';
        end;

        if ServiceRec.Get(Rec."Service Code") then begin
            ServiceName := ServiceRec.Description;
        end else begin
            ServiceName := '';
        end;

        if VehicleRec.Get(Rec.NumVehicle) then begin
            if ClientRec.Get(VehicleRec."NumCustomer") then begin
                ClientName := ClientRec.Name;

            end
            else begin
                ClientName := 'vide';
            end;
        end;
    end;

    var
        ClientRec: Record StaCustomer;
        AgencyRec: Record Agency;
        ServiceRec: Record Service;
        VehicleRec: Record StaVehicle;
        AgencyName: Text[100];
        ServiceName: Text[100];
        ClientName: Text[100];
}