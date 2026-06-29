page 50110 MakeAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'make';
    EntitySetName = 'makes';

    SourceTable = Make;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(code; Rec.Code) { }
                field(name; Rec.Name) { }
            }
        }
    }
}