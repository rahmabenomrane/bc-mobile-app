page 50108 AgencyApi
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'Agency';
    EntitySetName = 'Agencies';
    SourceTable = Agency;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Agency Name';

                }
                field(Code; Rec.Code)
                {
                    Caption = 'Code';

                }
                field(Address; Rec.Address)
                {
                    Caption = 'Agency Address';

                }
                field(PhoneNo; Rec.PhoneNo)
                {
                    Caption = 'Phone Number';

                }
                field(Email; Rec.Email)
                {
                    Caption = 'Email';

                }
                field(Capacity; Rec.Capacity)
                {
                    Caption = 'Capacity';

                }
                field(OfficeHours; Rec."Office hours")
                {
                    Caption = 'Office Hours';
                }
                field(latitude; Rec.Latitude) { Caption = 'latitude'; }
                field(longitude; Rec.Longitude) { Caption = 'longitude'; }
            }
        }
    }
}