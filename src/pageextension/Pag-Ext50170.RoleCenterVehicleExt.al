pageextension 50170 RoleCenterVehicleExt extends "Service Advisor Role Center"
{

    actions
    {
        addlast(Sections)
        {
            group(STA)
            {
                Caption = 'STA Management';
                Image = Administration;

                action(Vehicules)
                {
                    Caption = 'Véhicules';
                    RunObject = Page 50111;
                    ApplicationArea = All;
                }

                action(Agences)
                {
                    Caption = 'Agences';
                    RunObject = Page 50130;
                    ApplicationArea = All;
                }

                action(Appointments)
                {
                    Caption = 'Rendez-vous';
                    RunObject = Page 50106;
                    ApplicationArea = All;
                }

                action(claims)
                {
                    Caption = 'Réclamations';
                    RunObject = Page 50129;
                    ApplicationArea = All;
                }
            }
        }
    }
}