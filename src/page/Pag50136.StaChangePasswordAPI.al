page 50136 StaChangePasswordAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';

    EntityName = 'changePassword';
    EntitySetName = 'changePasswords';

    SourceTable = StaCustomer;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(customerNumber; Rec.NumCustomer) { }
                field(currentPassword; CurrentPassword) { }
                field(newPassword; NewPassword) { }
            }
        }
    }

    var
        CurrentPassword: Text;
        NewPassword: Text;

    trigger OnModifyRecord(): Boolean
    var
        AuthMgt: Codeunit "STA Auth Management";
        Salt: Text;
    begin
        if not AuthMgt.VerifyPassword(Rec, CurrentPassword) then
            Error('Current password incorrect');

        Salt := AuthMgt.GenerateSalt();
        Rec.PasswordSalt := Salt;
        Rec.PasswordHash := AuthMgt.HashPassword(NewPassword, Salt);

        Rec.Modify(true);

        exit(false);
    end;
}