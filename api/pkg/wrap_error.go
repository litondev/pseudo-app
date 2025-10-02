package pkg

import (
	"fmt"
	"log"
	"runtime"
)

// RecoverPanic recovers from panic and logs the error
func RecoverPanic() {
	if r := recover(); r != nil {
		// Get stack trace
		buf := make([]byte, 1024)
		n := runtime.Stack(buf, false)
		stackTrace := string(buf[:n])
		
		// Log the panic
		log.Printf("PANIC RECOVERED: %v\nStack Trace:\n%s", r, stackTrace)
	}
}

// WrapError wraps an error with additional context
func WrapError(err error, message string) error {
	if err == nil {
		return nil
	}
	return fmt.Errorf("%s: %w", message, err)
}

// WrapErrorf wraps an error with formatted message
func WrapErrorf(err error, format string, args ...interface{}) error {
	if err == nil {
		return nil
	}
	message := fmt.Sprintf(format, args...)
	return fmt.Errorf("%s: %w", message, err)
}

// SafeExecute executes a function with panic recovery
func SafeExecute(fn func() error) (err error) {
	defer func() {
		if r := recover(); r != nil {
			// Get stack trace
			buf := make([]byte, 1024)
			n := runtime.Stack(buf, false)
			stackTrace := string(buf[:n])
			
			// Log the panic
			log.Printf("PANIC in SafeExecute: %v\nStack Trace:\n%s", r, stackTrace)
			
			// Convert panic to error
			err = fmt.Errorf("panic recovered: %v", r)
		}
	}()
	
	return fn()
}

// SafeExecuteWithCallback executes a function with panic recovery and callback
func SafeExecuteWithCallback(fn func() error, onPanic func(interface{})) (err error) {
	defer func() {
		if r := recover(); r != nil {
			// Get stack trace
			buf := make([]byte, 1024)
			n := runtime.Stack(buf, false)
			stackTrace := string(buf[:n])
			
			// Log the panic
			log.Printf("PANIC in SafeExecuteWithCallback: %v\nStack Trace:\n%s", r, stackTrace)
			
			// Call callback if provided
			if onPanic != nil {
				onPanic(r)
			}
			
			// Convert panic to error
			err = fmt.Errorf("panic recovered: %v", r)
		}
	}()
	
	return fn()
}

// LogError logs error with context
func LogError(err error, context string) {
	if err != nil {
		log.Printf("ERROR [%s]: %v", context, err)
	}
}

// LogErrorf logs error with formatted context
func LogErrorf(err error, format string, args ...interface{}) {
	if err != nil {
		context := fmt.Sprintf(format, args...)
		log.Printf("ERROR [%s]: %v", context, err)
	}
}