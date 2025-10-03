package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	logDir := "../../logger"
	
	// Get absolute path
	absLogDir, err := filepath.Abs(logDir)
	if err != nil {
		log.Fatalf("Error getting absolute path: %v", err)
	}

	fmt.Printf("Starting log cleanup process at %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("Target directory: %s\n", absLogDir)

	// Check if logger directory exists
	if _, err := os.Stat(absLogDir); os.IsNotExist(err) {
		fmt.Printf("Logger directory does not exist: %s\n", absLogDir)
		return
	}

	// Count and delete .log files
	deletedCount := 0
	totalSize := int64(0)

	err = filepath.Walk(absLogDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Printf("Error accessing path %s: %v\n", path, err)
			return nil // Continue walking
		}

		// Check if file has .log extension
		if !info.IsDir() && strings.HasSuffix(strings.ToLower(info.Name()), ".log") {
			fileSize := info.Size()
			
			// Attempt to delete the file
			if err := os.Remove(path); err != nil {
				fmt.Printf("Error deleting file %s: %v\n", path, err)
				return nil // Continue with other files
			}
			
			deletedCount++
			totalSize += fileSize
			fmt.Printf("Deleted: %s (Size: %d bytes)\n", path, fileSize)
		}

		return nil
	})

	if err != nil {
		log.Fatalf("Error walking through directory: %v", err)
	}

	// Summary
	fmt.Printf("\n=== Log Cleanup Summary ===\n")
	fmt.Printf("Files deleted: %d\n", deletedCount)
	fmt.Printf("Total space freed: %.2f KB (%.2f MB)\n", 
		float64(totalSize)/1024, 
		float64(totalSize)/(1024*1024))
	fmt.Printf("Cleanup completed at: %s\n", time.Now().Format("2006-01-02 15:04:05"))

	// Log the cleanup activity
	logCleanupActivity(deletedCount, totalSize)
}

// logCleanupActivity logs the cleanup activity to a separate cleanup log
func logCleanupActivity(filesDeleted int, totalSize int64) {
	logFile := "../../logger/cleanup_history.log"
	
	// Create or append to cleanup history log
	file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		fmt.Printf("Warning: Could not create cleanup history log: %v\n", err)
		return
	}
	defer file.Close()

	logEntry := fmt.Sprintf("[%s] Log cleanup executed - Files deleted: %d, Space freed: %.2f MB\n",
		time.Now().Format("2006-01-02 15:04:05"),
		filesDeleted,
		float64(totalSize)/(1024*1024))

	if _, err := file.WriteString(logEntry); err != nil {
		fmt.Printf("Warning: Could not write to cleanup history log: %v\n", err)
	}
}