sub Main()
    print "Starting Real-Debrid Player..."
    
    ' Try to create screen
    screen = CreateObject("roScreen", true)
    if screen = invalid
        print "ERROR: Cannot create roScreen in simulator"
        print "The brs-engine simulator has limited graphics support"
        RunTextMode()
        return
    end if
    
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    
    ' Initialize API
    m.api = CreateRealDebridAPI()
    
    ' UI State
    m.state = {
        mode: "menu"  ' menu, search, results
        selectedIndex: 0
        searchQuery: ""
        searchResults: []
        menuItems: ["Search Movies/TV", "Test Video Player", "Exit"]
    }
    
    ' Colors
    m.colors = {
        background: &h202020FF
        text: &hFFFFFFFF
        selected: &h00FF00FF
        header: &h0088FFFF
        box: &h404040FF
    }
    
    ' Get user info
    userInfo = m.api.getUserInfo()
    if userInfo <> invalid
        m.username = userInfo.username
    else
        m.username = "Not Connected"
    end if
    
    ' Main loop
    while true
        DrawUI(screen, m.state, m.colors, m.username)
        screen.SwapBuffers()
        
        msg = wait(100, port)
        if type(msg) = "roUniversalControlEvent"
            handled = HandleInput(msg.GetInt(), m.state, m.api)
            if not handled then exit while
        end if
    end while
    
    screen.Clear(0)
    screen.SwapBuffers()
end sub

sub DrawUI(screen, state, colors, username)
    ' Clear screen with background color
    screen.Clear(colors.background)
    
    ' Draw header box
    screen.DrawRect(0, 0, 1280, 80, colors.header)
    screen.DrawRect(10, 10, 1260, 60, colors.box)
    
    ' Draw main content area
    screen.DrawRect(20, 100, 1240, 500, colors.box)
    
    if state.mode = "menu"
        DrawMenu(screen, state, colors)
    else if state.mode = "search"
        DrawSearch(screen, state, colors)
    else if state.mode = "results"
        DrawSearchResults(screen, state, colors)
    end if
    
    ' Draw footer
    screen.DrawRect(0, 620, 1280, 100, colors.box)
end sub

sub DrawMenu(screen, state, colors)
    ' Draw menu title area
    screen.DrawRect(40, 120, 400, 40, colors.header)
    
    ' Draw menu items as boxes
    y = 200
    for i = 0 to state.menuItems.Count() - 1
        if i = state.selectedIndex
            ' Highlight selected item
            screen.DrawRect(40, y, 600, 60, colors.selected)
            screen.DrawRect(45, y + 5, 590, 50, colors.background)
        else
            screen.DrawRect(40, y, 600, 60, colors.box)
        end if
        y = y + 80
    end for
end sub

sub DrawSearch(screen, state, colors)
    ' Draw search title
    screen.DrawRect(40, 120, 400, 40, colors.header)
    
    ' Draw search input box
    screen.DrawRect(40, 220, 800, 60, colors.text)
    screen.DrawRect(45, 225, 790, 50, colors.background)
    
    ' Draw cursor
    if state.searchQuery = ""
        screen.DrawRect(50, 230, 20, 40, colors.text)
    else
        ' Show query length as blocks
        for i = 0 to Len(state.searchQuery) - 1
            screen.DrawRect(50 + (i * 15), 230, 10, 40, colors.text)
        end for
        ' Cursor at end
        screen.DrawRect(50 + (Len(state.searchQuery) * 15), 230, 20, 40, colors.selected)
    end if
    
    ' Draw instruction box
    screen.DrawRect(40, 320, 400, 40, colors.box)
end sub

function PlayTorrentDirectly(result as Object, api as Object)
    print "Playing instantly available torrent: "; result.title
    
    ShowLoadingDialog("Streaming", "Getting stream link...")
    
    streamData = api.getStreamFromTorrent(result.magnet, result.info_hash)
    
    CloseLoadingDialog()
    
    if streamData <> invalid and streamData.success = true
        print "Got stream URL: "; streamData.stream_url
        return PlayVideo(streamData.stream_url, result.title, "Real-Debrid Stream")
    else
        ShowErrorDialog("Error", "Could not get stream link")
        return false
    end if
end function

function ShowTorrentOptions(result as Object, api as Object)
    dialog = CreateObject("roMessageDialog")
    port = CreateObject("roMessagePort")
    dialog.SetMessagePort(port)
    
    dialog.SetTitle("Torrent Options")
    dialog.SetText("'" + result.title + "'" + Chr(10) + Chr(10) + "This torrent is not instantly available.")
    dialog.AddButton(1, "Add to Real-Debrid")
    dialog.AddButton(2, "Cancel")
    dialog.Show()
    
    while true
        msg = wait(0, port)
        if type(msg) = "roMessageDialogEvent"
            if msg.IsButtonPressed()
                if msg.GetIndex() = 1
                    print "Adding magnet: "; result.magnet
                    response = api.addMagnet(result.magnet)
                    if response <> invalid
                        ShowInfoDialog("Added", "Torrent added to Real-Debrid. It will be available for streaming once downloaded.")
                    else
                        ShowErrorDialog("Error", "Failed to add torrent")
                    end if
                end if
                exit while
            else if msg.IsScreenClosed()
                exit while
            end if
        end if
    end while
end function

sub DrawSearchResults(screen, state, colors)
    ' Draw title
    screen.DrawRect(40, 120, 400, 40, colors.header)
    
    if state.searchResults.Count() = 0
        ' No results message
        screen.DrawRect(40, 200, 600, 60, colors.box)
    else
        ' Draw result items with availability indicators
        y = 200
        for i = 0 to Min(4, state.searchResults.Count() - 1)
            if i = state.selectedIndex
                screen.DrawRect(40, y, 1000, 90, colors.selected)
                screen.DrawRect(45, y + 5, 990, 80, colors.background)
            else
                screen.DrawRect(40, y, 1000, 90, colors.box)
            end if
            
            ' Draw availability indicator
            result = state.searchResults[i]
            if result.instant_available = true
                ' Green dot for instantly available
                screen.DrawRect(50, y + 15, 20, 20, &h00FF00FF)
            else
                ' Red dot for not available
                screen.DrawRect(50, y + 15, 20, 20, &hFF0000FF)
            end if
            
            y = y + 100
        end for
    end if
end sub

function HandleInput(key, state, api)
    if key = 0 then return true  ' No key pressed
    
    print "Key pressed: "; key
    
    if key = 2 or key = 38  ' Up arrow
        if state.selectedIndex > 0
            state.selectedIndex = state.selectedIndex - 1
        end if
    else if key = 3 or key = 40  ' Down arrow
        maxIndex = 0
        if state.mode = "menu"
            maxIndex = state.menuItems.Count() - 1
        else if state.mode = "results"
            maxIndex = Min(4, state.searchResults.Count() - 1)
        end if
        
        if state.selectedIndex < maxIndex
            state.selectedIndex = state.selectedIndex + 1
        end if
    else if key = 6 or key = 13  ' OK/Enter
        if state.mode = "menu"
            if state.selectedIndex = 0  ' Search
                state.mode = "search"
                state.searchQuery = ""
                state.selectedIndex = 0
                print "Entering search mode"
            else if state.selectedIndex = 1  ' Test Video Player
                print "Testing video player..."
                TestVideoPlayback()
            else if state.selectedIndex = 2  ' Exit
                return false
            end if
        else if state.mode = "search"
            if Len(state.searchQuery) > 0
                print "Searching for: "; state.searchQuery
                state.searchResults = api.searchTorrents(state.searchQuery)
                state.mode = "results"
                state.selectedIndex = 0
            end if
        else if state.mode = "results"
            if state.selectedIndex < state.searchResults.Count()
                result = state.searchResults[state.selectedIndex]
                print "Selected: "; result.title
                
                ' Show options based on availability
                if result.instant_available = true
                    StreamTorrentNow(result.magnet, result.info_hash, result.title, api)
                else
                    ShowTorrentOptions(result, api)
                end if
            end if
        end if
    else if key = 0 or key = 27 or key = 8  ' Back/Escape
        if state.mode <> "menu"
            state.mode = "menu"
            state.selectedIndex = 0
            print "Returning to menu"
        end if
    else if key >= 32 and key <= 126  ' Printable characters for search
        if state.mode = "search"
            state.searchQuery = state.searchQuery + Chr(key)
            print "Search query: "; state.searchQuery
        end if
    else if key = 127  ' Delete key
        if state.mode = "search" and Len(state.searchQuery) > 0
            state.searchQuery = Left(state.searchQuery, Len(state.searchQuery) - 1)
            print "Search query: "; state.searchQuery
        end if
    end if
    
    return true
end function

function Min(a, b)
    if a < b then return a
    return b
end function

function FormatFileSize(bytes)
    if bytes = invalid then return "Unknown"
    
    if bytes < 1024
        return Str(bytes) + " B"
    else if bytes < 1048576
        return Str(Int(bytes / 1024)) + " KB"
    else if bytes < 1073741824
        return Str(Int(bytes / 1048576)) + " MB"
    else
        gb = bytes / 1073741824.0
        return Mid(Str(gb), 2, 4) + " GB"
    end if
end function

sub RunTextMode()
    print "================================"
    print "   Real-Debrid Player (Text Mode)"
    print "================================"
    print ""
    
    ' Initialize API
    api = CreateRealDebridAPI()
    
    ' Get user info
    userInfo = api.getUserInfo()
    if userInfo <> invalid
        print "Logged in as: "; userInfo.username
        print "Premium until: "; userInfo.expiration
        print ""
    else
        print "Failed to connect to Real-Debrid API"
        return
    end if
    
    ' Show menu
    print "MAIN MENU:"
    print "[1] Search Torrents (simulated)"
    print "[2] View My Downloads"
    print "[3] View Active Torrents"
    print ""
    
    ' Get downloads
    print "Loading your downloads..."
    downloads = api.getDownloads()
    
    if downloads <> invalid and downloads.Count() > 0
        print ""
        print "YOUR DOWNLOADS ("; downloads.Count(); " total):"
        print "--------------------------------"
        
        for i = 0 to Min(10, downloads.Count() - 1)
            item = downloads[i]
            print "["; i + 1; "] "; item.filename
            print "    Size: "; FormatFileSize(item.filesize)
            print ""
        end for
        
        ' Simulate search
        print ""
        print "SEARCH SIMULATION:"
        searchResults = api.searchTorrents("test movie")
        if searchResults <> invalid
            print "Found "; searchResults.Count(); " results for 'test movie'"
            for each result in searchResults
                print "- "; result.title
                print "  Size: "; FormatFileSize(result.size); " | Seeds: "; result.seeders
            end for
        end if
    else
        print "No downloads found in your Real-Debrid account"
    end if
    
    print ""
    print "================================"
    print "Note: Full GUI requires a real Roku device"
    print "This simulator has limited UI support"
    print "================================"
end sub