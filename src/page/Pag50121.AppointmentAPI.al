page 50121 AppointmentAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'Appointment';
    EntitySetName = 'Appointments';
    SourceTable = Appointment;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("AgencyCode"; Rec."Agency Code")
                {
                    Caption = 'Agency Code';

                }
                field("ServiceCode"; Rec."Service Code")
                {
                    Caption = 'Service Code';

                }
                field("Date"; Rec."Date")
                {
                    Caption = 'Date';

                }
                field("Time"; Rec."Time")
                {
                    Caption = 'Time';

                }
                field("Status"; Rec."Status")
                {
                    Caption = 'Status';

                }
                field("NumVehicle"; Rec."NumVehicle")
                {
                    Caption = 'Vehicle No.';
                }
                field("AppointmentNo"; Rec."Appointment No.")
                {
                    Caption = 'Appointment No.';
                }
            }
        }
    }
}