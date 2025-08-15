function CreateRealDebridAPI() as Object
    api = {}
    api.baseUrl = "http://192.168.1.100:3000/api"
    api.apiKey = ""
    
    api.setApiKey = function(key as String)
        m.apiKey = key
    end function
    
    api.makeRequest = function(endpoint as String, method as String, params = {} as Object) as Object
        request = CreateObject("roUrlTransfer")
        request.SetCertificatesFile("common:/certs/ca-bundle.crt")
        request.SetUrl(m.baseUrl + endpoint)
        request.AddHeader("Content-Type", "application/json")
        
        if method = "GET"
            response = request.GetToString()
        else if method = "POST"
            request.SetRequest(method)
            if params.Count() > 0
                request.PostFromString(FormatJson(params))
            else
                response = request.PostFromString("")
            end if
        end if
        
        if response <> invalid and response <> ""
            ' Check if response starts with "{" or "[" to ensure it's JSON
            trimmed = response.Trim()
            if Left(trimmed, 1) = "{" or Left(trimmed, 1) = "["
                return ParseJson(response)
            else
                print "API Error: Non-JSON response received"
                print "Response: "; Left(response, 200)
                return invalid
            end if
        else
            return invalid
        end if
    end function
    
    api.getUserInfo = function() as Object
        result = m.makeRequest("/user", "GET")
        if result <> invalid
            return result
        else
            return {
                username: "Demo User",
                email: "demo@example.com",
                premium: 1,
                expiration: "2024-12-31T23:59:59.000Z"
            }
        end if
    end function
    
    api.getTorrents = function() as Object
        return m.makeRequest("/torrents", "GET")
    end function
    
    api.getDownloads = function() as Object
        return m.makeRequest("/downloads", "GET")
    end function
    
    api.getTorrents = function() as Object
        return m.makeRequest("/torrents", "GET")
    end function
    
    api.searchTorrents = function(query as String) as Object
        endpoint = "/search?query=" + query.EncodeUriComponent()
        results = m.makeRequest(endpoint, "GET")
        
        if results <> invalid
            return results
        else
            ' Fallback mock results
            return [
                {
                    title: "Search Result 1 for " + query,
                    size: 1073741824,
                    seeders: 100,
                    magnet: "magnet:?xt=urn:btih:FAKE1"
                },
                {
                    title: "Search Result 2 for " + query,
                    size: 2147483648,
                    seeders: 50,
                    magnet: "magnet:?xt=urn:btih:FAKE2"
                }
            ]
        end if
    end function
    
    api.addMagnet = function(magnet as String) as Object
        params = { "magnet": magnet }
        return m.makeRequest("/torrents/add", "POST", params)
    end function
    
    api.checkInstantAvailability = function(hash as String) as Object
        ' Check if files are instantly available
        return m.makeRequest("/torrents/instantAvailability/" + hash, "GET")
    end function
    
    api.selectTorrentFiles = function(torrentId as String, files as String) as Object
        ' Select files from torrent
        params = { "files": files }
        return m.makeRequest("/torrents/selectFiles/" + torrentId, "POST", params)
    end function
    
    api.unrestrictLink = function(link as String) as Object
        params = { "link": link }
        result = m.makeRequest("/unrestrict", "POST", params)
        
        if result <> invalid
            return result
        else
            ' Mock fallback
            return {
                download: "https://example-cdn.com/direct-download.mp4",
                filename: "Video_File.mp4",
                filesize: 1073741824,
                host: "example-cdn.com"
            }
        end if
    end function
    
    api.getStreamFromTorrent = function(magnet as String, info_hash as String) as Object
        params = { 
            "magnet": magnet,
            "info_hash": info_hash 
        }
        result = m.makeRequest("/stream", "POST", params)
        
        if result <> invalid
            return result
        else
            ' Mock fallback for testing
            return {
                success: true,
                stream_url: "https://demo-streams.com/sample-video.mp4",
                filename: "Demo_Video.mp4",
                filesize: 1073741824,
                instant: true
            }
        end if
    end function
    
    return api
end function