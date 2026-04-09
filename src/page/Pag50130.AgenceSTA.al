page 50130 AgenceSTA
{
    PageType = List;
    SourceTable = Agency;
    Caption = 'Agences';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Agency Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }

                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }

                field(PhoneNo; Rec.PhoneNo)
                {
                    ApplicationArea = All;
                }

                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                }

                field(Capacity; Rec.Capacity)
                {
                    ApplicationArea = All;
                    Style = Strong;
                }

                field("Office hours"; Rec."Office hours")
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
            action(ViewAppointments)
            {
                Caption = 'Rendez-vous';
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
        }
    }
}