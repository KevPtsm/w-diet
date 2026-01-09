//
//  DatenschutzView.swift
//  w-diet
//
//  Local privacy policy view (DSGVO-compliant)
//

import SwiftUI

struct DatenschutzView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    Text("Datenschutzerklärung")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)

                    Text("Stand: Januar 2026")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Section 1: Verantwortlicher
                    section(title: "1. Verantwortlicher") {
                        Text("Verantwortlich für die Datenverarbeitung in dieser App ist:")
                        Text("Kevin Pietschmann\nkevin.pietschmann@student.uni-luebeck.de")
                            .padding()
                            .background(Theme.gray100)
                            .cornerRadius(8)
                    }

                    // Section 2: Welche Daten
                    section(title: "2. Welche Daten wir verarbeiten") {
                        bulletPoint("Gesundheitsdaten: Gewicht, Größe, Alter, Geschlecht, Aktivitätslevel")
                        bulletPoint("Ernährungsdaten: Mahlzeiten, Kalorien, Makronährstoffe")
                        bulletPoint("Accountdaten: E-Mail-Adresse")
                    }

                    // Section 3: Zweck
                    section(title: "3. Zweck der Verarbeitung") {
                        Text("Wir verarbeiten deine Daten ausschließlich zur:")
                        bulletPoint("Berechnung deines persönlichen Kalorienbedarfs")
                        bulletPoint("Verfolgung deiner Ernährungsziele")
                        bulletPoint("Bereitstellung der App-Funktionen")
                    }

                    // Section 4: Rechtsgrundlage
                    section(title: "4. Rechtsgrundlage") {
                        Text("Die Verarbeitung erfolgt auf Basis deiner ausdrücklichen Einwilligung (Art. 9 Abs. 2 lit. a DSGVO). Du kannst diese Einwilligung jederzeit widerrufen.")
                    }

                    // Section 5: Speicherung
                    section(title: "5. Datenspeicherung") {
                        bulletPoint("Lokal: Deine Daten werden primär auf deinem Gerät gespeichert")
                        bulletPoint("Cloud: Optional synchronisiert mit Supabase (EU-Server)")
                        bulletPoint("Löschung: Bei Kontolöschung werden alle Daten entfernt")
                    }

                    // Section 6: Deine Rechte
                    section(title: "6. Deine Rechte") {
                        Text("Du hast folgende Rechte:")
                        bulletPoint("Auskunft über deine gespeicherten Daten")
                        bulletPoint("Berichtigung unrichtiger Daten")
                        bulletPoint("Löschung deiner Daten")
                        bulletPoint("Datenübertragbarkeit (Export)")
                        bulletPoint("Widerruf deiner Einwilligung")
                        bulletPoint("Beschwerde bei einer Aufsichtsbehörde")
                    }

                    // Section 7: Export & Löschung
                    section(title: "7. Daten exportieren & löschen") {
                        Text("In den Einstellungen kannst du:")
                        bulletPoint("Alle deine Daten als JSON exportieren")
                        bulletPoint("Dein Konto und alle Daten vollständig löschen")
                    }

                    // Section 8: Kontakt
                    section(title: "8. Kontakt") {
                        Text("Bei Fragen zum Datenschutz erreichst du mich unter:")
                        Text("kevin.pietschmann@student.uni-luebeck.de")
                            .foregroundColor(Theme.fireGold)
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Components

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
        .font(.subheadline)
    }
}

#Preview {
    DatenschutzView()
}
