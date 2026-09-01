page 50133 "Agency Services Part"
{
    PageType = ListPart;
    SourceTable = Service;
    Caption = 'Services proposés';

    layout
    {
        area(Content)
        {
            repeater(Services)
            {
                field(ServiceCode; Rec.ServiceCode)
                {
                    Caption = 'Code';
                    ApplicationArea = All;
                    Editable = false;
                }


                field(Libelle; Rec.Libelle)
                {
                    Caption = 'Service';
                    ApplicationArea = All;
                    Editable = false;
                }


                field(Disponible; IsAvailable)
                {
                    Caption = 'Disponible';
                    ApplicationArea = All;


                    trigger OnValidate()
                    begin
                        UpdateAgencyService();
                    end;
                }
            }
        }
    }


    var
        AgencyCode: Code[20];
        IsAvailable: Boolean;


    procedure SetAgency(NewAgencyCode: Code[20])
    begin
        AgencyCode := NewAgencyCode;
    end;



    trigger OnAfterGetRecord()
    begin
        CheckAvailability();
    end;



    local procedure CheckAvailability()
    var
        ServiceAgence: Record ServiceAgence;
    begin

        ServiceAgence.Reset();

        ServiceAgence.SetRange(
            "Agency Code",
            AgencyCode);

        ServiceAgence.SetRange(
            "Service Code",
            Rec.ServiceCode);


        IsAvailable := ServiceAgence.FindFirst();

    end;



    local procedure UpdateAgencyService()
    var
        ServiceAgence: Record ServiceAgence;
    begin

        if IsAvailable then begin

            if not ServiceAgence.Get(
                AgencyCode,
                Rec.ServiceCode) then begin

                ServiceAgence.Init();

                ServiceAgence."Agency Code" := AgencyCode;
                ServiceAgence."Service Code" := Rec.ServiceCode;
                ServiceAgence.Disponible := true;

                ServiceAgence.Insert();

            end;

        end
        else begin

            if ServiceAgence.Get(
                AgencyCode,
                Rec.ServiceCode) then
                ServiceAgence.Delete();

        end;

    end;
}