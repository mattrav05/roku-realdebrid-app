function GetAppConfig() as Object
    return {
        serverUrl: "https://roku-realdebrid-app.vercel.app",
        apiEndpoint: "/api",
        version: "1.0.0",
        debug: false,
        videoFormats: ["mp4", "mkv", "avi", "mov", "wmv"],
        maxRetries: 3,
        requestTimeout: 30000
    }
end function

function GetServerUrl() as String
    config = GetAppConfig()
    return config.serverUrl + config.apiEndpoint
end function

function IsVideoFile(filename as String) as Boolean
    config = GetAppConfig()
    extension = LCase(Right(filename, 3))
    
    for each format in config.videoFormats
        if extension = format or LCase(Right(filename, Len(format))) = format
            return true
        end if
    end for
    
    return false
end function

function LogDebug(message as String)
    config = GetAppConfig()
    if config.debug
        print "[DEBUG] "; message
    end if
end function