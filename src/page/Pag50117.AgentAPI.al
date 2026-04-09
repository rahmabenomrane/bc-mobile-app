page 50117 AgentAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'Agent';
    EntitySetName = 'Agents';
    SourceTable = StaAgent;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("AgentNo"; Rec."Agent No.")
                {
                    Caption = 'Agent No.';

                }
                field("login"; Rec.login)
                {
                    Caption = 'Login';

                }
                field("Password"; Rec.Password)
                {
                    Caption = 'Password';

                }
                field("AgentType"; Rec."Agent Type")
                {
                    Caption = 'Agent Type';

                }
                field("NumAgency"; Rec."Num Agency")
                {
                    Caption = 'Num Agency';

                }
                field("HiringDate"; Rec."hiring date")
                {
                    Caption = 'Hiring Date';

                }
                field("AgentContext"; AgentContextTxt)
                {
                    Caption = 'Agent Context';
                }
            }
        }
    }
    var
        AgentContextTxt: Text[20];

    trigger OnAfterGetRecord()
    var
        AgencyRec: Record Agency;
    begin
        if AgencyRec.Get(Rec."Num Agency") then
            AgentContextTxt := Format(AgencyRec."Agency Type")
        else
            AgentContextTxt := '';
    end;

}
