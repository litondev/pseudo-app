package pkg

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

// FormatDecimalWithComma formats number to Indonesian format with comma (100000 -> 100.000,00)
func FormatDecimalWithComma(number float64) string {
	// Round to 2 decimal places
	rounded := math.Round(number*100) / 100
	
	// Split integer and decimal parts
	integerPart := int64(rounded)
	decimalPart := rounded - float64(integerPart)
	
	// Format integer part with dots as thousand separators
	integerStr := formatIntegerWithDots(integerPart)
	
	// Format decimal part
	decimalStr := fmt.Sprintf("%.2f", decimalPart)[2:] // Get "XX" from "0.XX"
	
	return integerStr + "," + decimalStr
}

// FormatDecimalWithoutComma formats number to Indonesian format without comma (100000.10 -> 100.000)
func FormatDecimalWithoutComma(number float64) string {
	// Round to nearest integer
	rounded := int64(math.Round(number))
	
	// Format with dots as thousand separators
	return formatIntegerWithDots(rounded)
}

// formatIntegerWithDots formats integer with dots as thousand separators
func formatIntegerWithDots(number int64) string {
	if number == 0 {
		return "0"
	}
	
	// Handle negative numbers
	negative := number < 0
	if negative {
		number = -number
	}
	
	// Convert to string and reverse for easier processing
	str := strconv.FormatInt(number, 10)
	runes := []rune(str)
	
	// Reverse the string
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	
	// Add dots every 3 digits
	var result []rune
	for i, r := range runes {
		if i > 0 && i%3 == 0 {
			result = append(result, '.')
		}
		result = append(result, r)
	}
	
	// Reverse back
	for i, j := 0, len(result)-1; i < j; i, j = i+1, j-1 {
		result[i], result[j] = result[j], result[i]
	}
	
	formatted := string(result)
	if negative {
		formatted = "-" + formatted
	}
	
	return formatted
}

// ParseIndonesianDecimal parses Indonesian formatted number back to float64
func ParseIndonesianDecimal(formatted string) (float64, error) {
	// Remove dots and replace comma with dot
	cleaned := strings.ReplaceAll(formatted, ".", "")
	cleaned = strings.ReplaceAll(cleaned, ",", ".")
	
	return strconv.ParseFloat(cleaned, 64)
}

// FormatCurrency formats number as Indonesian Rupiah currency
func FormatCurrency(amount float64) string {
	formatted := FormatDecimalWithComma(amount)
	return "Rp " + formatted
}