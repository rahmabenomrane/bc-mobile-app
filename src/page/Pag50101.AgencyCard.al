page 50101 "Agency Card"
{
    PageType = Card;
    SourceTable = Agency;
    Caption = 'Agence';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Informations générales';
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
                Caption = 'Informations de contact';
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        Geocode: Codeunit "Agency Geocode";
                        NewLat: Decimal;
                        NewLng: Decimal;
                    begin
                        if Rec.Address = '' then exit;

                        if Geocode.GeocodeAddress(Rec.Address, NewLat, NewLng) then begin
                            Rec.Latitude := NewLat;
                            Rec.Longitude := NewLng;
                            Rec.Modify(true);
                            CurrPage.AgencyMap.Page.SetCoordinates(NewLat, NewLng);
                        end else
                            Message('Adresse introuvable. Vérifiez la saisie ou cliquez directement sur la carte.');
                    end;
                }
                field(PhoneNo; Rec.PhoneNo) { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
            }

            group(Details)
            {
                Caption = 'Détails supplémentaires';
                field(Capacity; Rec.Capacity) { ApplicationArea = All; }
                field("Office hours"; Rec."Office hours") { ApplicationArea = All; }
                field("Base Calendar Code"; Rec."Base Calendar Code")
                {
                    ApplicationArea = All;
                    Caption = 'Calendrier (jours travaillés/chômés)';
                    ToolTip = 'Calendrier définissant les jours travaillés et chômés de cette agence.';
                }
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
                SubPageLink = Code = field(Code);
                UpdatePropagation = Both;
            }

            part(Ponts; "CarLift SubPage")
            {
                ApplicationArea = All;
                Caption = 'Ponts';
                SubPageLink = "Agency Code" = field(Code);
            }
            part(AgencyServices; "Agency Services Part")
            {
                ApplicationArea = All;
                Caption = 'Services proposés';
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
            action(RefreshCalendar)
            {
                Caption = 'Régénérer le calendrier (90 jours)';
                Image = Refresh;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CalendarSync: Codeunit "Agency Calendar Sync";
                begin
                    CalendarSync.GenerateNonworkingDays(Rec.Code, 90);
                    Message('Calendrier régénéré pour les 90 prochains jours.');
                end;
            }
            action(OpenCalendar)
            {
                Caption = 'Gérer le calendrier';
                Image = Calendar;
                ApplicationArea = All;
                ToolTip = 'Définir les jours travaillés et les jours chômés de cette agence.';

                trigger OnAction()
                var
                    BaseCalendar: Record "Base Calendar";
                begin
                    if Rec."Base Calendar Code" = '' then begin
                        if not Confirm('Aucun calendrier associé à cette agence. Voulez-vous en créer un ?') then
                            exit;

                        BaseCalendar.Init();
                        BaseCalendar.Code := Rec.Code;
                        if BaseCalendar.Insert(true) then begin
                            Rec."Base Calendar Code" := BaseCalendar.Code;
                            Rec.Modify(true);
                        end;
                    end else begin
                        if not BaseCalendar.Get(Rec."Base Calendar Code") then
                            Error('Le calendrier %1 est introuvable.', Rec."Base Calendar Code");
                    end;

                    Page.Run(Page::"Base Calendar Card", BaseCalendar);
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

                    CurrPage.AgencyMap.Page.SetCoordinates(0, 0);
                    Message('Position GPS réinitialisée.');
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.AgencyServices.Page.SetAgency(Rec.Code);

        CurrPage.AgencyMap.Page.SetCoordinates(
            Rec.Latitude,
            Rec.Longitude);
    end;

}