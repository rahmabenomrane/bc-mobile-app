page 50137 "Claim Message ListPart"
{
    PageType = ListPart;
    SourceTable = ClaimMessage;
    Caption = 'Échanges avec le client';
    ApplicationArea = All;

    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Messages)
            {
                field(SenderType; Rec.SenderType)
                {
                    Caption = 'Expéditeur';
                    Editable = false;
                }

                field(SenderName; Rec.SenderName)
                {
                    Caption = 'Nom';
                    Editable = false;
                }

                field(Message; Rec.Message)
                {
                    Caption = 'Message';
                    MultiLine = true;

                    trigger OnValidate()
                    begin

                        Rec.TestField("Claim No.");
                        if Rec.SenderName = '' then begin
                            Rec.SenderType := Rec.SenderType::Agent;
                            Rec.SenderName :=
                                CopyStr(UserId, 1, MaxStrLen(Rec.SenderName));
                        end;

                        if Rec.MessageDateTime = 0DT then
                            Rec.MessageDateTime := CurrentDateTime;
                    end;
                }

                field(MessageDateTime; Rec.MessageDateTime)
                {
                    Caption = 'Date et heure';
                    Editable = false;
                }
            }
        }
    }
    var
        CurrentClaimNo: Code[20];

    procedure SetClaimNo(ClaimNo: Code[20])
    begin
        CurrentClaimNo := ClaimNo;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Claim No." := CurrentClaimNo;

        Rec.SenderType := Rec.SenderType::Agent;

        Rec.SenderName :=
            CopyStr(UserId, 1, MaxStrLen(Rec.SenderName));

        Rec.MessageDateTime := CurrentDateTime;
    end;
}