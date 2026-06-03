page 50122 ServicesAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'Service';
    EntitySetName = 'Services';
    SourceTable = Service;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ServiceCode; Rec."ServiceCode")
                {
                    Caption = 'Service Code';

                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';

                }
                field(libelle; Rec.libelle)
                {
                    Caption = 'Libelle';

                }
                field(Type; Rec."Type Service")
                {
                    Caption = 'Type';

                }
            }
        }
    }
}
