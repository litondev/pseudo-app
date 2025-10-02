package pkg

import (
	"strings"
	"time"
)

// GetDaysInIndonesian returns a flat array of Indonesian day names
func GetDaysInIndonesian() []string {
	return []string{
		"Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu",
	}
}

// GetDayTranslationMap returns a map of English to Indonesian day names
func GetDayTranslationMap() map[string]string {
	return map[string]string{
		"sunday":    "minggu",
		"monday":    "senin",
		"tuesday":   "selasa",
		"wednesday": "rabu",
		"thursday":  "kamis",
		"friday":    "jumat",
		"saturday":  "sabtu",
	}
}

// TranslateDayToIndonesian translates English day name to Indonesian
func TranslateDayToIndonesian(englishDay string) string {
	dayMap := GetDayTranslationMap()
	if indonesianDay, exists := dayMap[strings.ToLower(englishDay)]; exists {
		return indonesianDay
	}
	return englishDay // return original if not found
}

// GetCurrentDayInIndonesian returns current day in Indonesian
func GetCurrentDayInIndonesian() string {
	now := time.Now()
	englishDay := now.Weekday().String()
	return TranslateDayToIndonesian(englishDay)
}

// FormatTimeToIndonesian formats time with Indonesian day name
func FormatTimeToIndonesian(t time.Time, layout string) string {
	englishDay := t.Weekday().String()
	indonesianDay := TranslateDayToIndonesian(englishDay)
	
	// Replace English day with Indonesian day in the formatted string
	formatted := t.Format(layout)
	formatted = strings.Replace(formatted, englishDay, indonesianDay, 1)
	
	return formatted
}