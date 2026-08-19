page 50124 CustomerList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = StaCustomer;
    Caption = 'Clients STA';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(NumCustomer; Rec.NumCustomer)
                {
                    ApplicationArea = All;
                    Caption = 'ID client';
                    Editable = false;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Nom';
                }

                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                    Caption = 'Téléphone';
                }

                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                    Caption = 'E-mail';
                }

                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    Caption = 'Adresse';
                }

                field(Civility; Rec.Civility)
                {
                    ApplicationArea = All;
                    Caption = 'Civilité';
                }

                field(BCStatus; BCStatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Statut client BC';
                    Editable = false;
                    StyleExpr = BCStatusStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateBCCustomer)
            {
                Caption = 'Créer la fiche client';
                ApplicationArea = All;
                Image = NewCustomer;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                Enabled = not CustomerExists;

                ToolTip =
        'Créer une fiche client Business Central à partir des informations du client STA.';

                trigger OnAction()
                begin
                    CreateAndOpenBCCustomer();
                end;
            }
            action(OpenCustomerCard)
            {
                Caption = 'Ouvrir la fiche client';
                ApplicationArea = All;
                Image = Customer;

                Promoted = true;
                PromotedCategory = Process;

                Enabled = CustomerExists;

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if FindCustomer(Customer) then
                        Page.Run(Page::"Customer Card", Customer)
                    else
                        Message(
                            'Aucune fiche client Business Central correspondante n''a été trouvée.'
                        );
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetCustomerStatus();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetCustomerStatus();
    end;

    var
        CustomerExists: Boolean;
        BCStatusText: Text[50];
        BCStatusStyle: Text;

    local procedure FindCustomer(var Customer: Record Customer): Boolean
    begin
        Customer.Reset();

        if Rec.Email <> '' then begin
            Customer.SetRange("E-Mail", Rec.Email);

            if Customer.FindFirst() then
                exit(true);
        end;

        Customer.Reset();

        if Rec.Phone <> '' then begin
            Customer.SetRange("Phone No.", Rec.Phone);

            if Customer.FindFirst() then
                exit(true);
        end;

        exit(false);
    end;

    local procedure OpenPrefilledCustomerCreation()
    var
        Customer: Record Customer;
        CustomerCard: Page "Customer Card";
    begin
        // Sécurité : vérifier que le client n'existe pas déjà
        if CustomerExists then begin
            Message('Une fiche client Business Central existe déjà pour ce client.');
            exit;
        end;

        // Important : repartir d'un nouvel enregistrement
        Clear(Customer);
        Customer.Init();

        // Préremplissage depuis StaCustomer
        if Rec.Name <> '' then
            Customer.Validate(Name, Rec.Name);

        if Rec.Address <> '' then
            Customer.Validate(Address, Rec.Address);

        if Rec.Phone <> '' then
            Customer.Validate("Phone No.", Rec.Phone);

        if Rec.Email <> '' then
            Customer.Validate("E-Mail", Rec.Email);

        // Ouvrir la fiche avec ces valeurs
        Clear(CustomerCard);
        CustomerCard.SetRecord(Customer);
        CustomerCard.RunModal();

        CurrPage.Update(false);
    end;

    local procedure SetCustomerStatus()
    var
        Customer: Record Customer;
    begin
        CustomerExists := FindCustomer(Customer);

        if CustomerExists then begin
            BCStatusText := 'Fiche créée';
            BCStatusStyle := 'Favorable';
        end else begin
            BCStatusText := 'À créer';
            BCStatusStyle := 'Attention';
        end;
    end;

    local procedure CreateAndOpenBCCustomer()
    var
        Customer: Record Customer;
    begin
        if CustomerExists then begin
            Message('Une fiche client Business Central existe déjà pour ce client.');
            exit;
        end;

        if Rec.Name = '' then
            Error('Le nom du client est obligatoire.');

        Customer.Init();

        // IMPORTANT :
        // On insère d'abord le nouveau client
        Customer.Insert(true);

        // Puis on préremplit les champs
        Customer.Validate(Name, Rec.Name);

        if Rec.Address <> '' then
            Customer.Validate(Address, Rec.Address);

        if Rec.Phone <> '' then
            Customer.Validate("Phone No.", Rec.Phone);

        if Rec.Email <> '' then
            Customer.Validate("E-Mail", Rec.Email);

        // Enregistrer les valeurs préremplies
        Customer.Modify(true);

        // Ouvrir EXACTEMENT le client qui vient d'être créé
        Page.Run(Page::"Customer Card", Customer);

        CurrPage.Update(false);
    end;
}