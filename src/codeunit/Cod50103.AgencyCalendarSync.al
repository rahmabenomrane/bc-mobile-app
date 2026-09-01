codeunit 50103 "Agency Calendar Sync"
{
    procedure GenerateNonworkingDays(AgencyCode: Code[20]; NbDays: Integer)
    var
        Agency: Record Agency;
        BaseCalendar: Record "Base Calendar";
        CustCalendarChange: Record "Customized Calendar Change";
        NonworkingDay: Record "Agency Nonworking Day";
        CalendarMgt: Codeunit "Calendar Management";
        CurrDate: Date;
        i: Integer;
    begin
        if not Agency.Get(AgencyCode) then
            exit;

        if Agency."Base Calendar Code" = '' then
            exit;

        if not BaseCalendar.Get(Agency."Base Calendar Code") then
            exit;

        // Nettoyer les anciennes entrées de cette agence
        NonworkingDay.SetRange("Agency Code", AgencyCode);
        NonworkingDay.DeleteAll();

        // Charger les règles du Base Calendar de cette agence
        CalendarMgt.SetSource(BaseCalendar, CustCalendarChange);

        CurrDate := Today();
        for i := 1 to NbDays do begin
            if CalendarMgt.IsNonworkingDay(CurrDate, CustCalendarChange) then begin
                NonworkingDay.Init();
                NonworkingDay."Agency Code" := AgencyCode;
                NonworkingDay.Date := CurrDate;
                NonworkingDay.Insert();
            end;
            CurrDate := CalcDate('<+1D>', CurrDate);
        end;
    end;
}