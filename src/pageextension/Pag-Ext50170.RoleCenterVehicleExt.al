pageextension 50170 RoleCenterVehicleExt extends "DLT Veh. ADV Role Center"
{
    actions
    {
        addafter("DLT Reservation")
        {
            group(STA)
            {
                Caption = 'STA Management';
                Image = Administration;


                action(Vehicules)
                {
                    Caption = 'Véhicules';
                    Image = Vehicle;
                    ApplicationArea = All;
                    RunObject = Page "StaVehicleList";
                }
                action(Agences)
                {
                    Caption = 'Agences';
                    Image = Agence;
                    ApplicationArea = All;
                    RunObject = Page "AgencyList";
                }

                action(Appointments)
                {
                    Caption = 'Rendez-vous';
                    Image = Calendar;
                    ApplicationArea = All;
                    RunObject = Page "STA rdv List";
                }
                action(Clients)
                {
                    Caption = 'Clients';
                    Image = Customer;
                    ApplicationArea = All;
                    RunObject = Page "CustomerList";
                }
            }
        }
    }
}