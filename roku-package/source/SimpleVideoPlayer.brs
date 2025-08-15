function PlayStreamDirectly(streamUrl as String, title as String) as Boolean
    print "Starting direct stream playback"
    print "Title: "; title
    print "URL: "; streamUrl
    
    ' Use roVideoScreen for simple, reliable playback
    videoScreen = CreateObject("roVideoScreen")
    port = CreateObject("roMessagePort")
    videoScreen.SetMessagePort(port)
    
    ' Simple content metadata
    content = {
        Title: title,
        SubTitle: "Real-Debrid Stream",
        StreamFormat: "mp4"
    }
    
    ' Auto-detect format based on URL
    lowerUrl = LCase(streamUrl)
    if InStr(1, lowerUrl, ".m3u8") > 0 or InStr(1, lowerUrl, "hls") > 0
        content.StreamFormat = "hls"
        print "Using HLS format"
    else if InStr(1, lowerUrl, ".mkv") > 0
        content.StreamFormat = "mkv"
        print "Using MKV format"
    else
        content.StreamFormat = "mp4"
        print "Using MP4 format"
    end if
    
    ' Add stream URL
    content.Stream = {
        Url: streamUrl,
        Quality: "HD"
    }
    
    ' Try to start playback
    videoScreen.SetContent(content)
    videoScreen.Show()
    
    ' Wait for events
    while true
        msg = wait(0, port)
        
        if type(msg) = "roVideoScreenEvent"
            if msg.IsScreenClosed()
                print "Video screen closed by user"
                return false
            else if msg.IsFullResult()
                print "Video finished playing completely"
                return true
            else if msg.IsPartialResult()
                print "Video stopped early"
                return false
            else if msg.IsRequestFailed()
                print "Video request failed: "; msg.GetMessage()
                return false
            else if msg.IsStreamStarted()
                print "Video stream started successfully"
            end if
        end if
    end while
    
    return false
end function

function StreamTorrentNow(magnet as String, infoHash as String, title as String, api as Object) as Boolean
    print "Getting stream from torrent..."
    print "Title: "; title
    
    ' Show loading message
    ShowLoadingDialog("Getting Stream", "Please wait while we prepare your video...")
    
    ' Get stream URL from backend
    streamData = api.getStreamFromTorrent(magnet, infoHash)
    
    CloseLoadingDialog()
    
    if streamData <> invalid and streamData.success = true
        print "Got stream URL: "; streamData.stream_url
        
        ' Use simple direct playback
        return PlayStreamDirectly(streamData.stream_url, title)
    else
        ShowErrorDialog("Stream Error", "Could not get stream link for this torrent")
        return false
    end if
end function

function TestVideoPlayback() as Boolean
    print "Testing video playback with sample stream"
    
    ' Test with a known working stream
    testUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    
    return PlayStreamDirectly(testUrl, "Test Video - Big Buck Bunny")
end function