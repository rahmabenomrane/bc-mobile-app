page 50131 ModelAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'model';
    EntitySetName = 'models';

    SourceTable = Model;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(code; Rec.Code) { }
                field(makeCode; Rec."Make Code") { }
                field(name; Rec."Commercial Name") { }
            }
        }
    }
}