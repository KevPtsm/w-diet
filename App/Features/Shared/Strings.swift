//
//  Strings.swift
//  w-diet
//
//  Centralized string constants for localization
//

import Foundation

/// Centralized UI strings for localization
enum Strings {
    // MARK: - Common

    enum Common {
        static let save = "Speichern"
        static let cancel = "Abbrechen"
        static let delete = "Löschen"
        static let edit = "Bearbeiten"
        static let today = "Heute"
        static let yesterday = "Gestern"
        static let soon = "Soon"
        static let tip = "Tipp"
        static let noResults = "Keine Ergebnisse"
        static let loading = "Lädt..."
        static let error = "Fehler"
    }

    // MARK: - Dashboard

    enum Dashboard {
        static let weighIn = "Auf die Waage!"
        static let dailyCheckIn = "Dein täglicher Check-in"
        static let noCycle = "Kein aktiver Zyklus"
    }

    // MARK: - Meal Logging

    enum MealLogging {
        static let addFood = "Essen hinzufügen"
        static let scanPlate = "Teller scannen"
        static let searchFood = "Lebensmittel suchen"
        static let manualEntry = "Manuell eingeben"
        static let plate = "Teller"
        static let nutritionLabel = "Nährwerte"
        static let barcode = "Barcode"
        static let noMeals = "Noch keine Mahlzeiten"
        static let addMeal = "Mahlzeit hinzufügen"
        static let meal = "Mahlzeit"
        static let macros = "Makronährstoffe"
        static let calories = "Kalorien"
        static let caloriesAutoCalculated = "Automatisch berechnet aus Makros"
        static let amountGrams = "Menge (Gramm)"
        static let productSearching = "Produkt wird gesucht..."
        static let searching = "Suche..."
        static let tryDifferentSearch = "Versuche einen anderen Suchbegriff."
        static let enterFoodName = "Gib den Namen eines Lebensmittels ein um in der Datenbank zu suchen."
    }

    // MARK: - Plate Scanner

    enum PlateScanner {
        static let takePhoto = "Foto aufnehmen"
        static let chooseFromPhotos = "Aus Fotos wählen"
        static let photographFood = "Fotografiere dein Essen"
        static let aiAnalysis = "Die KI analysiert das Bild und schätzt die Nährwerte"
        static let analyzing = "Analysiere Mahlzeit..."
        static let recognizedFood = "Erkannte Lebensmittel"
        static let newPhoto = "Neues Foto"
        static func accuracy(_ confidence: String) -> String {
            "Genauigkeit: \(confidence)"
        }
    }

    // MARK: - Nutrition Label

    enum NutritionLabel {
        static let recognizing = "Erkenne Nährwerte..."
        static let productName = "Produktname"
        static let portion = "Portion"
        static let amount = "Menge"
        static let nutritionValues = "Nährwerte"
        static let noNutritionRecognized = "Keine Nährwerte erkannt"
        static let photographNutritionTable = "Bitte fotografiere die Nährwerttabelle auf der Verpackung"
        static let valuesRecognizedPer100g = "Nährwerte werden pro 100g erkannt und auf deine Portion umgerechnet"
    }

    // MARK: - Barcode Scanner

    enum BarcodeScanner {
        static let positionBarcode = "Barcode im Rahmen positionieren"
        static let cameraPermissionNeeded = "Bitte erlaube den Kamera-Zugriff in den Einstellungen, um Barcodes zu scannen."
    }

    // MARK: - Weight

    enum Weight {
        static let trend = "Trend"
        static let moreDataNeeded = "Mehr Daten benötigt"
        static let howMuchToday = "Wie viel wiegst du heute?"
        static let dailyWeighingHelps = "Tägliches Wiegen hilft dir, deinen Fortschritt zu tracken"
        static let saveWeight = "Gewicht speichern"
        static let editExistingEntry = "Vorhandenen Eintrag bearbeiten"
        static func weightFor(_ dateString: String) -> String {
            "Gewicht für \(dateString)"
        }
    }

    // MARK: - Onboarding

    enum Onboarding {
        static let whatIsYourGoal = "Was ist dein Ziel?"
        static let howTallAreYou = "Wie groß bist du?"
        static let howOldAreYou = "Wie alt bist du?"
        static let howMuchDoYouWeigh = "Wieviel wiegst du?"
        static let howActiveAreYou = "Wie aktiv bist du?"
        static let yourPersonalGoal = "Dein persönliches Ziel"
        static let thisIsOnlyGuideline = "Das ist nur ein Richtwert"
        static let calorieAdjustmentTip = "Du kannst dein Kalorienziel jederzeit in den Einstellungen anpassen."
        static let relevantForCalories = "Dies ist relevant für die Kalorienberechnung."
        static let ready = "Bereit!"
        static let letsGo = "Los geht's"
        static let beforeWeStart = "Bevor's losgeht..."
        static let dataStaysWithYou = "Deine Daten bleiben bei dir."
        static let slideToConfirm = "Zum Bestätigen schieben"
        static let loseWeight = "Abnehmen"
    }

    // MARK: - MATADOR

    enum Matador {
        static let diet = "Diät"
        static let maintenance = "Erhalt"
        static let thisIsMatador = "Das ist MATADOR"
        static let normalDiet = "Normale Diät"
        static let constantDeficit = "Konstantes"
        static let deficit = "Defizit"
        static let metabolismCrashed = "Stoffwechsel\ncrashed"
        static let yoyoEffect = "Jojo-Effekt"
        static let metabolismStaysActive = "Stoffwechsel\nbleibt aktiv"
        static let weightLoss = "Gewichtsverlust"
        static let readMatadorStudy = "MATADOR Studie lesen"
        static let caloriesTrend = "Kalorien Trend"
    }

    // MARK: - Intermittent Fasting

    enum IntermittentFasting {
        static let thisIsIF = "Das ist Intervallfasten"
        static let chooseEatingWindow = "Wähle dein 6 Stunden Essensfenster"
        static let recommendedTime = "Empfohlene Zeit"
        static let calorieFreeAllowed = "Kalorienfreie Getränke sind außerhalb des Essfensters erlaubt."
        static let readIFStudy = "Intervallfasten-Studie lesen"
    }

    // MARK: - Settings

    enum Settings {
        static let profile = "Profil"
        static let appearance = "Darstellung"
        static let privacy = "Datenschutz"
        static let language = "Sprache"
        static let german = "Deutsch"
        static let dangerZone = "Gefahrenzone"
        static let app = "App"
        static let profileResetWarning = "Dein Profil wird zurückgesetzt und du musst das Onboarding erneut durchlaufen."
        static let deleteDataWarning = "Alle deine Daten werden unwiderruflich gelöscht. Diese Aktion kann nicht rückgängig gemacht werden."
        static let cycleResetWarning = "Der MATADOR-Zyklus wird auf Tag 1 (Diätphase) zurückgesetzt."
    }

    // MARK: - Errors

    enum Errors {
        static let analysisFailed = "Analyse fehlgeschlagen"
        static let saveFailed = "Speichern fehlgeschlagen"
        static let notLoggedIn = "Nicht angemeldet"
        static let unknownError = "Unbekannter Fehler"
    }

    // MARK: - Delete Confirmations

    enum DeleteConfirmation {
        static func deleteAllEntries(_ count: Int) -> String {
            "Alle \(count) Einträge in dieser Mahlzeit werden gelöscht."
        }
    }
}
