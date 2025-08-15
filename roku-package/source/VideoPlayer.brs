function PlayVideo(url as String, title as String, subtitle = "" as String) as Boolean
    print "Playing video: "; title
    print "Stream URL: "; url
    
    ' Create video player
    video = CreateObject("roVideoPlayer")
    port = CreateObject("roMessagePort")
    video.SetMessagePort(port)
    
    ' Set up content metadata for Roku native player
    content = {
        Title: title,
        Description: subtitle,
        StreamUrls: [url],
        StreamBitrates: [0],
        StreamQualities: ["HD"]
    }
    
    ' Auto-detect stream format and set appropriate properties
    if InStr(1, LCase(url), ".m3u8") > 0 or InStr(1, url, "hls") > 0
        print "Detected HLS stream"
        content.StreamFormat = "hls"
    else if InStr(1, LCase(url), ".mkv") > 0
        print "Detected MKV stream"
        content.StreamFormat = "mkv"
    else if InStr(1, LCase(url), ".mp4") > 0 or InStr(1, url, "mp4") > 0
        print "Detected MP4 stream"
        content.StreamFormat = "mp4"
    else
        print "Using default MP4 format"
        content.StreamFormat = "mp4"
    end if
    
    ' Set content and start playback
    video.SetContent(content)
    video.Play()
    
    ' Event loop for video player
    while true
        msg = wait(0, port)
        
        if type(msg) = "roVideoPlayerEvent"
            print "Video player event: "; msg.GetType()
            
            if msg.IsRequestSucceeded()
                print "Video request succeeded"
            else if msg.IsRequestFailed()
                print "Video request failed"
                ShowErrorDialog("Playback Error", "Failed to load video stream")
                return false
            else if msg.IsStatusMessage()
                print "Video status: "; msg.GetMessage()
            else if msg.IsPlaybackPosition()
                ' Video is playing
                position = msg.GetIndex()
                print "Playback position: "; position
            else if msg.IsFullResult()
                print "Video finished playing"
                return true
            else if msg.IsPartialResult()
                print "Video playback ended early"
                return true
            else if msg.IsStreamStarted()
                print "Video stream started successfully"
            end if
        else if type(msg) = "roUniversalControlEvent"
            ' Handle remote control input during playback
            key = msg.GetInt()
            if key = 0 or key = 8 or key = 27  ' Back button
                print "User pressed back, stopping playback"
                video.Stop()
                return false
            end if
        end if
    end while
    
    return false
end function

function ShowVideoOptions(item as Object, api as Object) as Boolean
    print "Showing video options for: "; item.filename
    
    ' Check if it's a video file
    if not IsVideoFile(item.filename)
        ShowErrorDialog("Not a Video", "This file does not appear to be a video file.")
        return false
    end if
    
    ' Create dialog
    dialog = CreateObject("roMessageDialog")
    port = CreateObject("roMessagePort")
    dialog.SetMessagePort(port)
    
    dialog.SetTitle(item.filename)
    dialog.SetText("Size: " + FormatFileSize(item.filesize) + Chr(10) + "Host: " + item.host)
    
    dialog.AddButton(1, "Play Video")
    dialog.AddButton(2, "Get Direct Link")
    dialog.AddButton(3, "Cancel")
    
    dialog.Show()
    
    while true
        msg = wait(0, port)
        
        if type(msg) = "roMessageDialogEvent"
            if msg.IsButtonPressed()
                buttonIndex = msg.GetIndex()
                
                if buttonIndex = 1  ' Play Video
                    ' Unrestrict and play
                    ShowLoadingDialog("Loading", "Getting stream link...")
                    
                    unrestrictedData = api.unrestrictLink(item.download)
                    
                    CloseLoadingDialog()
                    
                    if unrestrictedData <> invalid and unrestrictedData.download <> invalid
                        return PlayVideo(unrestrictedData.download, item.filename, "Real-Debrid Stream")
                    else
                        ShowErrorDialog("Error", "Failed to get stream link")
                        return false
                    end if
                    
                else if buttonIndex = 2  ' Get Direct Link
                    ShowLoadingDialog("Loading", "Getting direct link...")
                    
                    unrestrictedData = api.unrestrictLink(item.download)
                    
                    CloseLoadingDialog()
                    
                    if unrestrictedData <> invalid and unrestrictedData.download <> invalid
                        ShowInfoDialog("Direct Link", unrestrictedData.download)
                    else
                        ShowErrorDialog("Error", "Failed to get direct link")
                    end if
                    
                    return false
                    
                else if buttonIndex = 3  ' Cancel
                    return false
                end if
            else if msg.IsScreenClosed()
                return false
            end if
        end if
    end while
    
    return false
end function

function ShowErrorDialog(title as String, message as String)
    dialog = CreateObject("roMessageDialog")
    port = CreateObject("roMessagePort")
    dialog.SetMessagePort(port)
    
    dialog.SetTitle(title)
    dialog.SetText(message)
    dialog.AddButton(1, "OK")
    dialog.Show()
    
    while true
        msg = wait(0, port)
        if type(msg) = "roMessageDialogEvent"
            if msg.IsButtonPressed() or msg.IsScreenClosed()
                exit while
            end if
        end if
    end while
end function

function ShowInfoDialog(title as String, message as String)
    dialog = CreateObject("roMessageDialog")
    port = CreateObject("roMessagePort")
    dialog.SetMessagePort(port)
    
    dialog.SetTitle(title)
    dialog.SetText(message)
    dialog.AddButton(1, "OK")
    dialog.Show()
    
    while true
        msg = wait(0, port)
        if type(msg) = "roMessageDialogEvent"
            if msg.IsButtonPressed() or msg.IsScreenClosed()
                exit while
            end if
        end if
    end while
end function

function ShowLoadingDialog(title as String, message as String)
    m.loadingDialog = CreateObject("roOneLineDialog")
    m.loadingDialog.SetTitle(title)
    m.loadingDialog.SetText(message)
    m.loadingDialog.ShowBusyAnimation()
    m.loadingDialog.Show()
end function

function CloseLoadingDialog()
    if m.loadingDialog <> invalid
        m.loadingDialog.Close()
        m.loadingDialog = invalid
    end if
end function

function CreateVideoList(downloads as Object) as Object
    videoList = []
    
    for each item in downloads
        if IsVideoFile(item.filename)
            videoList.Push(item)
        end if
    end for
    
    return videoList
end function