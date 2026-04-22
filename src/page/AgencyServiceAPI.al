page 50125 AgencyServiceAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'agencyService';
    EntitySetName = 'agencyServices';
    SourceTable = ServiceAgence;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(agencyCode; Rec."Agency Code")
                {
                    Caption = 'Agency Code';
                }

                field(serviceCode; Rec."Service Code")
                {
                    Caption = 'Service Code';
                }

                field(prix; Rec."Prix")
                {
                    Caption = 'Price';
                }

                field(duree; Rec."Duree")
                {
                    Caption = 'Duration';
                }

                field(disponible; Rec."Disponible")
                {
                    Caption = 'Available';
                }
            }
        }
    }
}