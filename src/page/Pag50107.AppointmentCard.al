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
                Caption = 'Informations générales';

                field("Appointment No."; Rec."Appointment No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Caption = 'N° rendez-vous';
                }

                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Caption = 'Statut';
                }
            }

            group("Appointment Details")
            {
                Caption = 'Détails du rendez-vous';

                field("Agency Name"; AgencyName)
                {
                    ApplicationArea = All;
                    Caption = 'Agence';
                    TableRelation = Agency.Name;
                }

                field("Agency Address"; AgencyAddress)
                {
                    ApplicationArea = All;
                    Caption = 'Adresse de l''agence';
                }

                field("Service"; ServiceDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Service';
                    Editable = false;
                }

                field("vehicle registration Number"; registrationNumber)
                {
                    ApplicationArea = All;
                    Caption = 'N° d''immatriculation';

                    trigger OnValidate()
                    begin
                        LoadVehicleInformations();
                    end;
                }

                field("Brand"; MakeCode)
                {
                    ApplicationArea = All;
                    Caption = 'Marque';
                }

                field("Model"; ModelCode)
                {
                    ApplicationArea = All;
                    Caption = 'Modèle';
                }

                field("Client"; ClientName)
                {
                    ApplicationArea = All;
                    Caption = 'Client';
                    Editable = false;
                }

                field("Client Phone"; ClientPhone)
                {
                    ApplicationArea = All;
                    Caption = 'Téléphone du client';
                    Editable = false;
                }
            }

            group("Schedule")
            {
                Caption = 'Planification';

                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                }

                field("StartTime"; Rec."StartTime")
                {
                    ApplicationArea = All;
                    Caption = 'Heure de début';
                }

                field("EndTime"; Rec."EndTime")
                {
                    ApplicationArea = All;
                    Caption = 'Heure de fin';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Cancel)
            {
                Caption = 'Annuler';
                Image = Cancel;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Pending;
                    Rec.Modify();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // AGENCE
        if AgencyRec.Get(Rec."Agency Code") then begin
            AgencyName := AgencyRec.Name;
            AgencyAddress := AgencyRec.Address;
        end
        else begin
            AgencyName := '';
            AgencyAddress := '';
        end;

        // SERVICE
        if ServiceRec.Get(Rec."Service Code") then
            ServiceDescription := ServiceRec.Description
        else
            ServiceDescription := '';

        LoadVehicleInformations();
    end;

    local procedure LoadVehicleInformations()
    begin
        // VEHICULE
        if VehicleRec.Get(Rec.NumVehicle) then begin

            MakeCode := VehicleRec."Make Code";
            ModelCode := VehicleRec."Model Code";
            registrationNumber := VehicleRec.RegistrationNumber;
            // CLIENT
            if ClientRec.Get(VehicleRec.NumCustomer) then begin
                ClientName := ClientRec.Name;
                ClientPhone := ClientRec.Phone;
            end
            else begin
                ClientName := '';
                ClientPhone := '';
            end;

        end
        else begin
            MakeCode := '';
            ModelCode := '';
            ClientName := '';
            ClientPhone := '';
            registrationNumber := '';
        end;
    end;

    var
        AgencyRec: Record Agency;
        VehicleRec: Record StaVehicle;

        ServiceRec: Record Service;
        ServiceDescription: Text[100];
        ModelCode: Text[50];
        AgencyName: Text[100];
        AgencyAddress: Text[150];
        MakeCode: Text[50];
        registrationNumber: Text[20];

        ClientRec: Record StaCustomer;
        ClientName: Text[100];
        ClientPhone: Text[20];
}