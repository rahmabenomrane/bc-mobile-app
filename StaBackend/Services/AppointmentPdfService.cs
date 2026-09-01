using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using StaBackend.Models;

namespace StaBackend.Services;

public class AppointmentPdfService
    : IAppointmentPdfService
{
    public byte[] Generate(
        AppointmentShareInfo rdv)
    {
        return Document
            .Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);

                    page.Margin(40);

                    page.DefaultTextStyle(
                        style =>
                            style.FontSize(11)
                    );

                    // ==========================
                    // HEADER
                    // ==========================

                    page.Header()
                        .Column(column =>
                        {
                            column.Item()
                                .AlignCenter()
                                .Text("STA")
                                .FontSize(30)
                                .Bold()
                                .FontColor(
                                    Colors.Blue.Darken2
                                );

                            column.Item()
                                .PaddingTop(5)
                                .AlignCenter()
                                .Text(
                                    "Confirmation de rendez-vous"
                                )
                                .FontSize(20)
                                .Bold();

                            column.Item()
                                .PaddingTop(8)
                                .AlignCenter()
                                .Text(
                                    $"N° {rdv.AppointmentNo}"
                                )
                                .FontSize(13)
                                .FontColor(
                                    Colors.Grey.Darken2
                                );
                        });

                    // ==========================
                    // CONTENT
                    // ==========================

                    page.Content()
                        .PaddingVertical(30)
                        .Column(column =>
                        {
                            column.Spacing(12);

                            // ------------------
                            // RENDEZ-VOUS
                            // ------------------

                            AddSection(
                                column,
                                "RENDEZ-VOUS"
                            );

                            AddRow(
                                column,
                                "Numéro",
                                rdv.AppointmentNo
                            );

                            AddRow(
                                column,
                                "Date",
                                rdv.AppointmentDate
                            );

                            AddRow(
                                column,
                                "Heure",
                                rdv.AppointmentTime
                            );

                            AddRow(
                                column,
                                "Statut",
                                rdv.Status
                            );

                            // ------------------
                            // SERVICE
                            // ------------------

                            AddSection(
                                column,
                                "SERVICE"
                            );

                            AddRow(
                                column,
                                "Service",
                                rdv.ServiceName
                            );

                            // ------------------
                            // VEHICULE
                            // ------------------

                            AddSection(
                                column,
                                "VÉHICULE"
                            );

                            AddRow(
                                column,
                                "Véhicule",
                                rdv.VehicleName
                            );

                            AddRow(
                                column,
                                "Immatriculation",
                                rdv.VehicleRegistration
                            );

                            // ------------------
                            // AGENCE
                            // ------------------

                            AddSection(
                                column,
                                "AGENCE STA"
                            );

                            AddRow(
                                column,
                                "Agence",
                                rdv.AgencyName
                            );

                            AddRow(
                                column,
                                "Adresse",
                                rdv.AgencyAddress
                            );

                            AddRow(
                                column,
                                "Téléphone",
                                rdv.AgencyPhone
                            );

                            // ------------------
                            // CLIENT
                            // ------------------

                            AddSection(
                                column,
                                "CLIENT"
                            );

                            AddRow(
                                column,
                                "E-mail",
                                rdv.CustomerEmail
                            );
                        });

                    // ==========================
                    // FOOTER
                    // ==========================

                    page.Footer()
                        .AlignCenter()
                        .Column(column =>
                        {
                            column.Item()
                                .Text(
                                    "Document généré par STA Mobile"
                                )
                                .FontSize(9)
                                .FontColor(
                                    Colors.Grey.Darken1
                                );

                            column.Item()
                                .AlignCenter()
                                .Text(text =>
                                {
                                    text.Span("Page ");

                                    text.CurrentPageNumber();

                                    text.Span(" / ");

                                    text.TotalPages();
                                });
                        });
                });
            })
            .GeneratePdf();
    }

    // ==========================================================
    // TITRE SECTION
    // ==========================================================

    private static void AddSection(
        ColumnDescriptor column,
        string title)
    {
        column.Item()
            .PaddingTop(12)
            .PaddingBottom(5)
            .BorderBottom(1)
            .BorderColor(
                Colors.Grey.Lighten2
            )
            .Text(title)
            .FontSize(13)
            .Bold()
            .FontColor(
                Colors.Blue.Darken2
            );
    }

    // ==========================================================
    // LIGNE INFORMATION
    // ==========================================================

    private static void AddRow(
        ColumnDescriptor column,
        string label,
        string? value)
    {
        column.Item()
            .Row(row =>
            {
                row.RelativeItem(1)
                    .Text(label)
                    .SemiBold();

                row.RelativeItem(2)
                    .Text(
                        string.IsNullOrWhiteSpace(value)
                            ? "Non renseigné"
                            : value
                    );
            });
    }
}