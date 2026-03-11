page 50123 AppointmentList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DLT Appointment";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(NRDV; Rec."Appointment No.")
                {
                    Caption = 'N° rendez-vous';
                }
                field(NomClient; Rec."Sell-to Customer No.")
                {
                    Caption = 'Nom Client';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}