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
            }

            group(Details)
            {
                Caption = 'Additional Details';

                field(Capacity; Rec.Capacity)
                {
                    ApplicationArea = All;
                }

                field("Office hours"; Rec."Office hours")
                {
                    ApplicationArea = All;
                }
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
        }
    }

}