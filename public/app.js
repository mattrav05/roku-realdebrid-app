const API_URL = '/api';

let currentUser = null;
let currentTorrents = [];
let currentDownloads = [];

document.addEventListener('DOMContentLoaded', () => {
    initializeTabs();
    loadUserInfo();
    checkAuthStatus();
    
    document.getElementById('searchBtn').addEventListener('click', searchTorrents);
    document.getElementById('searchInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') searchTorrents();
    });
    
    document.getElementById('refreshDownloads').addEventListener('click', loadDownloads);
    document.getElementById('startAuth').addEventListener('click', startAuthentication);
    document.getElementById('checkToken').addEventListener('click', checkTokenStatus);
    document.getElementById('testConnection').addEventListener('click', testConnection);
    
    document.querySelector('.close').addEventListener('click', closeModal);
    document.getElementById('modalCancel').addEventListener('click', closeModal);
});

function initializeTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const targetTab = button.getAttribute('data-tab');
            
            tabButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');
            
            tabContents.forEach(content => {
                content.style.display = 'none';
            });
            
            document.getElementById(`${targetTab}-tab`).style.display = 'block';
            
            if (targetTab === 'downloads') {
                loadDownloads();
            } else if (targetTab === 'torrents') {
                loadTorrents();
            }
        });
    });
}

async function loadUserInfo() {
    try {
        const response = await fetch(`${API_URL}/user`);
        if (response.ok) {
            currentUser = await response.json();
            document.getElementById('username').textContent = currentUser.username || 'Guest';
            document.getElementById('premium').textContent = currentUser.premium ? 
                `Premium until ${new Date(currentUser.expiration).toLocaleDateString()}` : 
                'Free Account';
        } else {
            document.getElementById('username').textContent = 'Not Connected';
            document.getElementById('premium').textContent = 'Check API Key';
        }
    } catch (error) {
        console.error('Error loading user info:', error);
        document.getElementById('username').textContent = 'Connection Error';
        document.getElementById('premium').textContent = '';
    }
}

async function searchTorrents() {
    const query = document.getElementById('searchInput').value.trim();
    if (!query) return;
    
    const resultsContainer = document.getElementById('searchResults');
    resultsContainer.innerHTML = '<div class="loading">Searching...</div>';
    
    try {
        const response = await fetch(`${API_URL}/search?query=${encodeURIComponent(query)}`);
        const results = await response.json();
        
        if (results.length === 0) {
            resultsContainer.innerHTML = '<div class="no-results">No results found</div>';
            return;
        }
        
        resultsContainer.innerHTML = results.map(result => `
            <div class="result-item">
                <div class="item-title">
                    ${result.instant_available ? '🟢' : '🔴'} ${escapeHtml(result.title)}
                    ${result.instant_available ? '<span class="status-badge status-completed">INSTANT</span>' : '<span class="status-badge status-waiting">DOWNLOAD NEEDED</span>'}
                </div>
                <div class="item-meta">
                    <span>Size: ${formatFileSize(result.size)}</span>
                    <span>Seeders: ${result.seeders}</span>
                    <span>Indexer: ${result.indexer || result.provider || 'Unknown'}</span>
                </div>
                <div class="item-actions">
                    ${result.instant_available ? `
                        <button class="btn-small btn-success" onclick="streamTorrent('${escapeHtml(result.magnet)}', '${escapeHtml(result.info_hash)}', '${escapeHtml(result.title)}')">
                            🎬 Stream Now
                        </button>
                    ` : `
                        <button class="btn-small" onclick="addMagnetFromSearch('${escapeHtml(result.magnet)}', '${escapeHtml(result.title)}')">
                            Add to Real-Debrid
                        </button>
                    `}
                </div>
            </div>
        `).join('');
    } catch (error) {
        console.error('Error searching:', error);
        resultsContainer.innerHTML = '<div class="error">Error searching torrents</div>';
    }
}

async function loadDownloads() {
    const container = document.getElementById('downloadsList');
    container.innerHTML = '<div class="loading">Loading downloads...</div>';
    
    try {
        const response = await fetch(`${API_URL}/downloads`);
        currentDownloads = await response.json();
        
        if (currentDownloads.length === 0) {
            container.innerHTML = '<div class="no-results">No downloads found</div>';
            return;
        }
        
        container.innerHTML = currentDownloads.map(download => `
            <div class="download-item">
                <div class="item-title">${escapeHtml(download.filename)}</div>
                <div class="item-meta">
                    <span>Size: ${formatFileSize(download.filesize)}</span>
                    <span>Host: ${download.host}</span>
                    <span>Added: ${new Date(download.generated).toLocaleString()}</span>
                </div>
                <div class="item-actions">
                    <button class="btn-small btn-success" onclick="unrestrictLink('${escapeHtml(download.link)}')">
                        Get Stream Link
                    </button>
                    <button class="btn-small" onclick="copyToClipboard('${escapeHtml(download.download)}')">
                        Copy Direct Link
                    </button>
                </div>
            </div>
        `).join('');
    } catch (error) {
        console.error('Error loading downloads:', error);
        container.innerHTML = '<div class="error">Error loading downloads</div>';
    }
}

async function loadTorrents() {
    const container = document.getElementById('torrentsList');
    container.innerHTML = '<div class="loading">Loading torrents...</div>';
    
    try {
        const response = await fetch(`${API_URL}/torrents`);
        currentTorrents = await response.json();
        
        if (currentTorrents.length === 0) {
            container.innerHTML = '<div class="no-results">No active torrents</div>';
            return;
        }
        
        container.innerHTML = currentTorrents.map(torrent => {
            const progress = torrent.progress || 0;
            const statusClass = getStatusClass(torrent.status);
            
            return `
                <div class="torrent-item">
                    <div class="item-title">${escapeHtml(torrent.filename)}</div>
                    <div class="item-meta">
                        <span>Size: ${formatFileSize(torrent.bytes)}</span>
                        <span>Speed: ${formatFileSize(torrent.speed)}/s</span>
                        <span>Seeders: ${torrent.seeders}</span>
                        <span class="status-badge status-${statusClass}">${torrent.status}</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: ${progress}%"></div>
                    </div>
                    <div class="item-actions" style="margin-top: 15px;">
                        ${torrent.status === 'waiting_files_selection' ? `
                            <button class="btn-small btn-success" onclick="selectFiles('${torrent.id}')">
                                Select Files
                            </button>
                        ` : ''}
                        ${torrent.status === 'downloaded' ? `
                            <button class="btn-small btn-success" onclick="viewTorrentFiles('${torrent.id}')">
                                View Files
                            </button>
                        ` : ''}
                        <button class="btn-small btn-danger" onclick="deleteTorrent('${torrent.id}')">
                            Delete
                        </button>
                    </div>
                </div>
            `;
        }).join('');
    } catch (error) {
        console.error('Error loading torrents:', error);
        container.innerHTML = '<div class="error">Error loading torrents</div>';
    }
}

async function addMagnet() {
    const magnetInput = document.getElementById('magnetInput');
    const magnet = magnetInput.value.trim();
    const resultDiv = document.getElementById('addResult');
    
    if (!magnet) {
        showMessage(resultDiv, 'Please enter a magnet link', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/torrents/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ magnet })
        });
        
        if (response.ok) {
            const result = await response.json();
            showMessage(resultDiv, 'Torrent added successfully!', 'success');
            magnetInput.value = '';
            
            if (result.id) {
                setTimeout(() => {
                    selectFiles(result.id);
                }, 1000);
            }
        } else {
            const error = await response.json();
            showMessage(resultDiv, `Error: ${error.error}`, 'error');
        }
    } catch (error) {
        console.error('Error adding magnet:', error);
        showMessage(resultDiv, 'Error adding torrent', 'error');
    }
}

async function streamTorrent(magnet, infoHash, title) {
    try {
        // Show loading message
        showVideoPlayer(null, 'Loading stream...');
        
        const response = await fetch(`${API_URL}/stream`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                magnet: magnet,
                info_hash: infoHash 
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            // Show video player with the stream URL
            showVideoPlayer(result.stream_url, result.filename || title);
            console.log('Stream URL:', result.stream_url);
        } else {
            closeVideoPlayer();
            alert(`Stream not available: ${result.message || 'Unknown error'}`);
        }
    } catch (error) {
        console.error('Error getting stream:', error);
        closeVideoPlayer();
        alert('Error getting stream link');
    }
}

function showVideoPlayer(streamUrl, title) {
    // Remove existing player if any
    closeVideoPlayer();
    
    // Create video player modal
    const playerModal = document.createElement('div');
    playerModal.id = 'videoPlayerModal';
    playerModal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.95);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        z-index: 10000;
    `;
    
    if (streamUrl) {
        playerModal.innerHTML = `
            <div style="width: 90%; max-width: 1200px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h2 style="color: white; margin: 0;">${escapeHtml(title)}</h2>
                    <button onclick="closeVideoPlayer()" style="background: #ff4444; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer;">
                        ✕ Close
                    </button>
                </div>
                <video id="streamPlayer" controls autoplay style="width: 100%; max-height: 80vh; background: black;">
                    <source src="${streamUrl}" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
                <div style="margin-top: 20px; display: flex; gap: 10px;">
                    <button onclick="document.getElementById('streamPlayer').play()" style="padding: 10px 20px; background: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer;">
                        ▶ Play
                    </button>
                    <button onclick="document.getElementById('streamPlayer').pause()" style="padding: 10px 20px; background: #FF9800; color: white; border: none; border-radius: 5px; cursor: pointer;">
                        ⏸ Pause
                    </button>
                    <button onclick="window.open('${streamUrl}', '_blank')" style="padding: 10px 20px; background: #2196F3; color: white; border: none; border-radius: 5px; cursor: pointer;">
                        ⬇ Download
                    </button>
                    <button onclick="copyToClipboard('${streamUrl}')" style="padding: 10px 20px; background: #9C27B0; color: white; border: none; border-radius: 5px; cursor: pointer;">
                        📋 Copy URL
                    </button>
                </div>
            </div>
        `;
    } else {
        playerModal.innerHTML = `
            <div style="text-align: center;">
                <div style="border: 4px solid #f3f3f3; border-top: 4px solid #667eea; border-radius: 50%; width: 50px; height: 50px; animation: spin 2s linear infinite; margin: 0 auto;"></div>
                <h2 style="color: white; margin-top: 20px;">${escapeHtml(title)}</h2>
            </div>
            <style>
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            </style>
        `;
    }
    
    document.body.appendChild(playerModal);
}

window.closeVideoPlayer = function() {
    const player = document.getElementById('videoPlayerModal');
    if (player) {
        // Stop video if playing
        const video = player.querySelector('video');
        if (video) {
            video.pause();
            video.src = '';
        }
        player.remove();
    }
}

async function addMagnetFromSearch(magnet, title) {
    if (confirm(`Add "${title}" to Real-Debrid for future streaming?`)) {
        try {
            const response = await fetch(`${API_URL}/torrents/add`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ magnet })
            });
            
            if (response.ok) {
                const result = await response.json();
                alert('Torrent added successfully! It will be available for streaming once downloaded.');
                
                if (result.id) {
                    selectFiles(result.id);
                }
            } else {
                const error = await response.json();
                alert(`Error: ${error.error}`);
            }
        } catch (error) {
            console.error('Error adding magnet:', error);
            alert('Error adding torrent');
        }
    }
}

async function selectFiles(torrentId) {
    try {
        const response = await fetch(`${API_URL}/torrents/${torrentId}`);
        const torrentInfo = await response.json();
        
        if (torrentInfo.files && torrentInfo.files.length > 0) {
            showFileSelectionModal(torrentId, torrentInfo.files);
        } else {
            const fileIds = 'all';
            await submitFileSelection(torrentId, fileIds);
        }
    } catch (error) {
        console.error('Error getting torrent info:', error);
        alert('Error loading torrent files');
    }
}

function showFileSelectionModal(torrentId, files) {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modalBody');
    
    modalBody.innerHTML = `
        <div class="file-list">
            ${files.map((file, index) => `
                <div class="file-item">
                    <input type="checkbox" id="file-${file.id}" value="${file.id}" checked>
                    <label for="file-${file.id}" class="file-name">${escapeHtml(file.path)}</label>
                    <span class="file-size">${formatFileSize(file.bytes)}</span>
                </div>
            `).join('')}
        </div>
    `;
    
    document.getElementById('modalConfirm').onclick = async () => {
        const checkboxes = modalBody.querySelectorAll('input[type="checkbox"]:checked');
        const selectedIds = Array.from(checkboxes).map(cb => cb.value).join(',');
        
        if (selectedIds) {
            await submitFileSelection(torrentId, selectedIds);
            closeModal();
        } else {
            alert('Please select at least one file');
        }
    };
    
    modal.style.display = 'flex';
}

async function submitFileSelection(torrentId, files) {
    try {
        const response = await fetch(`${API_URL}/torrents/select/${torrentId}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ files })
        });
        
        if (response.ok) {
            alert('Files selected successfully! Download starting...');
            loadTorrents();
        } else {
            const error = await response.json();
            alert(`Error: ${error.error}`);
        }
    } catch (error) {
        console.error('Error selecting files:', error);
        alert('Error selecting files');
    }
}

async function deleteTorrent(torrentId) {
    if (confirm('Are you sure you want to delete this torrent?')) {
        try {
            const response = await fetch(`${API_URL}/torrents/${torrentId}`, {
                method: 'DELETE'
            });
            
            if (response.ok) {
                loadTorrents();
            } else {
                const error = await response.json();
                alert(`Error: ${error.error}`);
            }
        } catch (error) {
            console.error('Error deleting torrent:', error);
            alert('Error deleting torrent');
        }
    }
}

async function unrestrictLink(link) {
    try {
        const response = await fetch(`${API_URL}/unrestrict`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ link })
        });
        
        if (response.ok) {
            const result = await response.json();
            if (result.download) {
                window.open(result.download, '_blank');
            }
        } else {
            const error = await response.json();
            alert(`Error: ${error.error}`);
        }
    } catch (error) {
        console.error('Error unrestricting link:', error);
        alert('Error getting stream link');
    }
}

async function checkAvailability(hash) {
    try {
        const response = await fetch(`${API_URL}/torrents/instantAvailability/${hash}`);
        const availability = await response.json();
        
        if (availability && Object.keys(availability).length > 0) {
            alert('This torrent is instantly available on Real-Debrid!');
        } else {
            alert('This torrent needs to be downloaded first.');
        }
    } catch (error) {
        console.error('Error checking availability:', error);
        alert('Error checking availability');
    }
}

function closeModal() {
    document.getElementById('modal').style.display = 'none';
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        alert('Link copied to clipboard!');
    }).catch(err => {
        console.error('Error copying to clipboard:', err);
    });
}

function showMessage(element, message, type) {
    element.textContent = message;
    element.className = `result-message ${type}`;
    setTimeout(() => {
        element.className = 'result-message';
    }, 5000);
}

function formatFileSize(bytes) {
    if (!bytes || bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

function getStatusClass(status) {
    const statusMap = {
        'downloading': 'downloading',
        'downloaded': 'completed',
        'error': 'error',
        'waiting_files_selection': 'waiting',
        'queued': 'waiting',
        'uploading': 'downloading'
    };
    return statusMap[status] || 'waiting';
}

// Real-Debrid Authentication Functions
async function checkAuthStatus() {
    try {
        const response = await fetch(`${API_URL}/auth/status`);
        const status = await response.json();
        
        const authStatusDiv = document.getElementById('authStatus');
        const authFlowDiv = document.getElementById('authFlow');
        const authSuccessDiv = document.getElementById('authSuccess');
        
        if (status.authenticated) {
            authStatusDiv.style.display = 'none';
            authFlowDiv.style.display = 'none';
            authSuccessDiv.style.display = 'block';
        } else {
            authStatusDiv.innerHTML = '<p>⚠️ Not authenticated with Real-Debrid. Please authenticate to use streaming features.</p>';
            authFlowDiv.style.display = 'block';
            authSuccessDiv.style.display = 'none';
        }
    } catch (error) {
        console.error('Error checking auth status:', error);
        document.getElementById('authStatus').innerHTML = '<p>❌ Error checking authentication status</p>';
    }
}

async function startAuthentication() {
    try {
        const response = await fetch(`${API_URL}/auth/device`);
        const data = await response.json();
        
        if (data.user_code) {
            document.getElementById('authUrl').href = data.verification_url;
            document.getElementById('authUrl').textContent = data.verification_url;
            document.getElementById('userCode').textContent = data.user_code;
            document.getElementById('authCode').style.display = 'block';
            
            // Auto-open the authorization URL
            window.open(data.verification_url, '_blank');
            
            // Start polling for token
            window.authPolling = setInterval(checkTokenStatus, 5000);
        }
    } catch (error) {
        console.error('Error starting authentication:', error);
        alert('Failed to start authentication');
    }
}

async function checkTokenStatus() {
    try {
        const response = await fetch(`${API_URL}/auth/token`, {
            method: 'POST'
        });
        const data = await response.json();
        
        const tokenStatusDiv = document.getElementById('tokenStatus');
        
        if (data.success) {
            tokenStatusDiv.innerHTML = '<p class="success">✅ Authentication successful!</p>';
            
            // Stop polling
            if (window.authPolling) {
                clearInterval(window.authPolling);
            }
            
            // Refresh the page status
            setTimeout(() => {
                checkAuthStatus();
                loadUserInfo();
            }, 1000);
            
        } else if (data.pending) {
            tokenStatusDiv.innerHTML = '<p class="waiting">⏳ Waiting for authorization...</p>';
        } else {
            tokenStatusDiv.innerHTML = '<p class="error">❌ Authentication failed</p>';
        }
    } catch (error) {
        console.error('Error checking token:', error);
        document.getElementById('tokenStatus').innerHTML = '<p class="error">❌ Error checking token status</p>';
    }
}

async function testConnection() {
    try {
        const response = await fetch(`${API_URL}/user`);
        if (response.ok) {
            const userData = await response.json();
            alert(`✅ Connection successful!\nUser: ${userData.username}\nPremium: ${userData.premium ? 'Yes' : 'No'}`);
        } else {
            alert('❌ Connection failed');
        }
    } catch (error) {
        console.error('Error testing connection:', error);
        alert('❌ Connection test failed');
    }
}