page 50103 AgencyList
{
    PageType = List;
    SourceTable = Agency;
    CardPageId = "Agency Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { }
                field(Name; Rec.Name) { }
                field(Address; Rec.Address) { }
                field(PhoneNo; Rec.PhoneNo) { }
            }
        }

    }
}