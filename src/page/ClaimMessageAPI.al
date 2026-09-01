page 50134 "Claim Message API"
{
    PageType = API;
    SourceTable = ClaimMessage;

    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';

    EntityName = 'claimMessage';
    EntitySetName = 'claimMessages';

    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(entryNo; Rec."Entry No.")
                {
                }

                field(claimNo; Rec."Claim No.")
                {
                }

                field(message; Rec.Message)
                {
                }

                field(senderType; Rec.SenderType)
                {
                }

                field(senderName; Rec.SenderName)
                {
                }

                field(messageDateTime; Rec.MessageDateTime)
                {
                }
            }
        }
    }
}