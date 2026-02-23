table 50110 StaVehicle
{
    Caption = 'Vehicle';
    DataClassification = CustomerContent;

    fields
    {
        // === IDENTIFIANTS ===
        field(1; "Vehicle No."; Code[20])      
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }

        field(8; VIN; Code[20])
        {
            Caption = 'VIN';
            DataClassification = CustomerContent;
        }

        field(70; "Registration No."; Code[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }

        // === CARACTÉRISTIQUES ===
        field(10; "Make Code"; Code[20])
        {
            Caption = 'Make Code';
            DataClassification = CustomerContent;
        }

        field(20; "Model Code"; Code[20])
        {
            Caption = 'Model Code';
            DataClassification = CustomerContent;
        }

        field(25; "Model Version No."; Code[20])
        {
            Caption = 'Model Version No.';
            DataClassification = CustomerContent;
        }

        field(30; "Model Commercial Name"; Text[50])
        {
            Caption = 'Model Commercial Name';
            DataClassification = CustomerContent;
        }

        field(50; "Production Year"; Code[4])
        {
            Caption = 'Production Year';
            DataClassification = CustomerContent;
        }

        

        field(1200; "Interior Code"; Code[10])
        {
            Caption = 'Interior Code';
            DataClassification = CustomerContent;
        }

        // === STATUTS ===
        field(150; "Status Code"; Code[20])
        {
            Caption = 'Status Code';
            TableRelation = "Vehicle Status".Code;
            DataClassification = CustomerContent;
        }

        field(154; "Status Group Code"; Code[20])
        {
            Caption = 'Vehicle Status Group Code';
            TableRelation = "Vehicle Status Group".Code;
            DataClassification = CustomerContent;
        }

        field(270; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }

        field(730; Reserved; Boolean)
        {
            Caption = 'Reserved';
            DataClassification = CustomerContent;
        }

        field(670; Inventory; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
            InitValue = 1;
        }

        // === DATES ===
        field(290; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        
        field(280; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(340; "Sales Date"; Date)
        {
            Caption = 'Sales Date';
            DataClassification = CustomerContent;
        }
        
        field(3000; "First Registration Date"; Date)
        {
            Caption = 'First Registration Date';
            DataClassification = CustomerContent;
        }
        
        field(3500; "Next Vehicle Inspection Date"; Date)
        {
            Caption = 'Next Vehicle Inspection Date';
            DataClassification = CustomerContent;
        }
        
        // === RELATION AVEC CLIENT (du diagramme UML) ===
        field(3600; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
            ValidateTableRelation = true;
        }
        
        field(3650; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
               }
        
        field(3710; "Customer Vehicle ID"; Code[20])
        {
            Caption = 'Customer Vehicle ID';
            DataClassification = CustomerContent;
        }
        
        field(25006830; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        
        field(25006840; "Bill-To Customer Name"; Text[100])
        {
            Caption = 'Bill-To Customer Name';
            DataClassification = CustomerContent;
           }
        
        // === AUTRES RELATIONS TECHNIQUES ===
        field(3400; "Fixed Asset No."; Code[20])
        {
            Caption = 'Fixed Asset No.';
            TableRelation = "Fixed Asset"."No.";
            DataClassification = CustomerContent;
        }
        
        field(3730; "Rent Asset No."; Code[20])
        {
            Caption = 'Rent Asset No.';
            DataClassification = CustomerContent;
        }
        
        field(3200; "Serv. Ledger Entry Exist"; Boolean)
        {
            Caption = 'Serv. Ledger Entry Exist';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        // === CHAMPS TECHNIQUES ===
        field(770; "Tracking Code"; Code[10])
        {
            Caption = 'Tracking Code';
            DataClassification = CustomerContent;
        }
        
        field(780; "Tracking Description"; Text[30])
        {
            Caption = 'Vehicle Tracking Description';
            DataClassification = CustomerContent;
            }
        
        field(790; "Parent Component"; Code[20])
        {
            Caption = 'Parent Component';
            DataClassification = CustomerContent;
        }
        
        field(800; Components; Boolean)
        {
            Caption = 'Components';
            DataClassification = CustomerContent;
        }
        
        field(25006379; "Default Vehicle Acc. Cycle No."; Code[20])
        {
            Caption = 'Default Vehicle Acc. Cycle No.';
            DataClassification = CustomerContent;
        }
      
    }
    
    keys
    {
        // Clé primaire avec vehicleNo (renommé)
        key(PK; "Vehicle No.")
        {
            Clustered = true;
        }
        
       
    }
    
    fieldgroups
    {
        
    }
    
    // === VARIABLES ===
    var

    
    // === TRIGGERS ===
    trigger OnInsert()
    begin
        // Initialisation à la création
        if "Creation Date" = 0D then
            "Creation Date" := Today();
            
        if Inventory = 0 then
            Inventory := 1;
            
       
    end;
    
    trigger OnModify()
    begin
        
    end;
    
    trigger OnDelete()
    begin
    
    end;
    
}