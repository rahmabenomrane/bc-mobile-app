page 50103 AgenceList
{
    PageType = List;
    SourceTable = Agence;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { }
                field(Nom; Rec.Nom) { }
                field(Adresse; Rec.Adresse) { }
                field(Telephone; Rec.Telephone) { }
            }
        }
    }
}
