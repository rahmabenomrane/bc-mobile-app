page 50101 "Agency Card"
{
    PageType = Card;
    SourceTable = Agency;
    Caption = 'Agency';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Information';
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
            }

            group(Contact)
            {
                Caption = 'Contact Details';
                field(Address; Rec.Address) { ApplicationArea = All; }
                field(PhoneNo; Rec.PhoneNo) { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
            }

            group(Details)
            {
                Caption = 'Additional Details';
                field(Capacity; Rec.Capacity) { ApplicationArea = All; }
                field("Office hours"; Rec."Office hours") { ApplicationArea = All; }
            }

            group(GPS)
            {
                Caption = 'Coordonnées GPS';

                field(Latitude; Rec.Latitude)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                }
                field(Longitude; Rec.Longitude)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                }
                
            }

          
            part(AgencyMap; "Agency Map Part")
            {
                ApplicationArea = All;
                Caption = 'Carte GPS';
            }

            part(Ponts; "CarLift SubPage")
            {
                ApplicationArea = All;
                Caption = 'Ponts';
                SubPageLink = "Agency Code" = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Appointments)
            {
                Caption = 'Voir Rendez-vous';
                Image = List;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Appointment: Record Appointment;
                begin
                    Appointment.SetRange("Agency Code", Rec.Code);
                    Page.Run(Page::"STA rdv List", Appointment);
                end;
            }

            action(ResetGPS)
            {
                Caption = 'Réinitialiser GPS';
                Image = Delete;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    if not Confirm('Effacer la position GPS actuelle ?') then exit;
                    Rec.Latitude := 0;
                    Rec.Longitude := 0;
                    Rec.Modify(true);
                    // ← syntaxe correcte pour appeler une procédure de part
                    CurrPage.AgencyMap.Page.SetCoordinates(0, 0);
                    Message('Position GPS réinitialisée.');
                end;
            }
        }
    }

    var
        GPSStyle: Text;

    trigger OnAfterGetRecord()
    begin
        RefreshMap();
    end;


    local procedure RefreshMap()
    begin
        CurrPage.AgencyMap.Page.SetCoordinates(Rec.Latitude, Rec.Longitude);
    end;


}