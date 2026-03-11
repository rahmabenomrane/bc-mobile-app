table 50100 Agency
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20]) { }
        field(2; Name; Text[100]) { }
        field(3; Address; Text[150]) { }
        field(4; PhoneNo; Text[20]) { }
        field(5; Email; Text[100]) {  }
        field(6;capacity; Integer) {  }
        field(7;"Office hours"; Text[100]) {  }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}