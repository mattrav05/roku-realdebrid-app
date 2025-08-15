sub init()
    print "FileListScene init"
    m.fileList = m.top.findNode("fileList")
    m.statusLabel = m.top.findNode("statusLabel")
    
    m.fileList.observeField("itemSelected", "onFileSelected")
    m.fileList.setFocus(true)
    
    ' Initialize Real-Debrid API
    m.rdAPI = CreateRealDebridAPI()
    
    ' Load files from Real-Debrid
    loadFiles()
end sub

sub loadFiles()
    m.statusLabel.text = "Loading files from Real-Debrid..."
    
    ' Get API key from registry (you'll need to implement storage)
    apiKey = getStoredApiKey()
    
    if apiKey <> ""
        m.rdAPI.setApiKey(apiKey)
        
        ' Get downloads
        downloads = m.rdAPI.getDownloads()
        
        if downloads <> invalid
            content = CreateObject("roSGNode", "ContentNode")
            
            for each download in downloads
                item = CreateObject("roSGNode", "ContentNode")
                item.title = download.filename
                item.description = "Size: " + formatFileSize(download.filesize)
                item.url = download.download
                item.id = download.id
                content.appendChild(item)
            end for
            
            m.fileList.content = content
            m.statusLabel.text = "Found " + downloads.Count().ToStr() + " files"
        else
            m.statusLabel.text = "Failed to load files. Check your API key."
        end if
    else
        m.statusLabel.text = "No API key found. Please login first."
    end if
end sub

sub onFileSelected()
    selectedItem = m.fileList.content.getChild(m.fileList.itemSelected)
    if selectedItem <> invalid
        print "Selected file:", selectedItem.title
        print "Download URL:", selectedItem.url
        
        ' Play the selected file
        playVideo(selectedItem.url, selectedItem.title)
    end if
end sub

sub playVideo(url as String, title as String)
    videoPlayer = CreateObject("roSGNode", "Video")
    videoPlayer.content = CreateObject("roSGNode", "ContentNode")
    videoPlayer.content.url = url
    videoPlayer.content.title = title
    videoPlayer.content.streamFormat = "mp4"
    
    videoPlayer.control = "play"
    m.top.appendChild(videoPlayer)
end sub

function getStoredApiKey() as String
    ' TODO: Implement secure storage for API key
    ' For now, return empty string
    return ""
end function

function formatFileSize(bytes as Integer) as String
    if bytes < 1024
        return bytes.ToStr() + " B"
    else if bytes < 1048576
        return (bytes / 1024).ToStr() + " KB"
    else if bytes < 1073741824
        return (bytes / 1048576).ToStr() + " MB"
    else
        return (bytes / 1073741824).ToStr() + " GB"
    end if
end function