package pkg

// GetImageFolders returns array of image folder names
func GetImageFolders() []string {
	return []string{
		"logo",
		"products",
	}
}

// GetAllAssetFolders returns all asset folder names including images and files
func GetAllAssetFolders() map[string][]string {
	return map[string][]string{
		"images": GetImageFolders(),
		"files": {
			"documents",
			"exports",
			"uploads",
		},
	}
}

// IsValidImageFolder checks if folder name is valid for images
func IsValidImageFolder(folderName string) bool {
	folders := GetImageFolders()
	for _, folder := range folders {
		if folder == folderName {
			return true
		}
	}
	return false
}

// GetAssetPath returns full asset path for given type and folder
func GetAssetPath(assetType, folderName string) string {
	basePath := "./asset/"
	return basePath + assetType + "/" + folderName + "/"
}

// GetImagePath returns full image path for given folder
func GetImagePath(folderName string) string {
	return GetAssetPath("images", folderName)
}

// GetFilePath returns full file path for given folder
func GetFilePath(folderName string) string {
	return GetAssetPath("files", folderName)
}