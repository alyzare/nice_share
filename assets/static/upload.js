// DOM Elements
const uploadArea = document.getElementById("uploadArea");
const dropZone = document.getElementById("dropZone");
const fileInput = document.getElementById("fileInput");
const browseButton = document.getElementById("browseButton");
const fileListContainer = document.getElementById("fileListContainer");
const fileList = document.getElementById("fileList");
const startUploadBtn = document.getElementById("startUploadBtn");
const progressContainer = document.getElementById("progressContainer");

let selectedFiles = [];
let sessionId = null;
let uploadToken = null;

// Format file size
function formatFileSize(bytes) {
  if (bytes === 0) return "0 Bytes";
  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
}

// Show loading state
function showLoadingState() {
  const dropZoneContent = dropZone.querySelector('.drop-zone-content');
  dropZoneContent.innerHTML = `
    <div class="loading-spinner"></div>
    <p class="loading-text">Requesting upload session...</p>
  `;
  startUploadBtn.disabled = true;
  startUploadBtn.style.opacity = "0.5";
  startUploadBtn.style.cursor = "not-allowed";
}

// Reset to normal state
function resetToNormalState() {
  const dropZoneContent = dropZone.querySelector('.drop-zone-content');
  dropZoneContent.innerHTML = `
    <svg class="upload-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48"
         viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
         stroke-linecap="round" stroke-linejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <polyline points="17 8 12 3 7 8"/>
      <line x1="12" y1="3" x2="12" y2="15"/>
    </svg>
    <p class="drop-zone-text">Browse or drag files here</p>
    <input type="file" id="fileInput" multiple style="display: none;"/>
    <button type="button" id="browseButton" class="browse-btn">Browse Files</button>
  `;

  // Re-attach event listeners
  const newBrowseButton = document.getElementById("browseButton");
  const newFileInput = document.getElementById("fileInput");

  newBrowseButton.addEventListener("click", (e) => {
    e.stopPropagation();
    newFileInput.click();
  });

  newFileInput.addEventListener("change", (e) => {
    if (e.target.files.length > 0) {
      addFiles(e.target.files);
    }
  });

  startUploadBtn.disabled = false;
  startUploadBtn.style.opacity = "1";
  startUploadBtn.style.cursor = "pointer";
}

// Show session state after acceptance
function showSessionState(sessionId) {
  const dropZoneContent = dropZone.querySelector('.drop-zone-content');
  dropZoneContent.innerHTML = `
    <div class="session-info">
      <svg class="session-icon" xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
        <polyline points="22 4 12 14.01 9 11.01"/>
      </svg>
      <p class="session-title">Upload Session Ready</p>
      <p class="session-id">Session ID: <strong>${escapeHtml(sessionId)}</strong></p>
      <p class="session-info-text">Uploading files...</p>
    </div>
  `;

  // Remove the upload button
  startUploadBtn.style.display = "none";
}

// Update file list display
function updateFileList() {
  const uploadArea = document.getElementById("uploadArea");

  if (selectedFiles.length === 0) {
    uploadArea.classList.remove("with-files");
    fileListContainer.style.display = "none";
    return;
  }

  uploadArea.classList.add("with-files");
  fileListContainer.style.display = "block";

  fileList.innerHTML = "";

  selectedFiles.forEach((file, index) => {
    const fileItem = document.createElement("div");
    fileItem.className = "file-item";
    fileItem.setAttribute("data-index", index);

    fileItem.innerHTML = `
      <div class="file-info">
        <svg class="file-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/>
          <polyline points="13 2 13 9 20 9"/>
        </svg>
        <div class="file-details">
          <div class="file-name" title="${escapeHtml(file.name)}">${escapeHtml(file.name)}</div>
          <div class="file-size">${formatFileSize(file.size)}</div>
        </div>
      </div>
      <button class="remove-file" data-index="${index}">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18"/>
          <line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
      </button>
    `;

    fileList.appendChild(fileItem);
  });

  document.querySelectorAll(".remove-file").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      const index = parseInt(btn.getAttribute("data-index"));
      removeFileAtIndex(index);
    });
  });
}

// Remove file from selection
function removeFileAtIndex(index) {
  selectedFiles.splice(index, 1);
  updateFileList();
}

// Add files to selection
function addFiles(files) {
  const validFiles = Array.from(files).filter(file => file.size > 0);
  selectedFiles.push(...validFiles);
  updateFileList();
  fileInput.value = "";
}

// Escape HTML to prevent XSS
function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

// Request upload session from server with timeout (simpler version)
async function requestUploadSession() {
  const filesData = selectedFiles.map(file => ({
    name: file.name,
    size: file.size,
    type: file.type
  }));

  // Create abort controller for timeout
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 10000); // 30 second timeout

  try {
    const response = await fetch("/web/upload-request", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        files: filesData
      }),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      throw new Error(`Server responded with status ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      throw new Error('Request timeout - server did not respond');
    }
    throw error;
  }
}

// Create a progress item element
function createProgressItem(file, index) {
  const progressItem = document.createElement("div");
  progressItem.className = "progress-item";
  progressItem.setAttribute("data-index", index);

  const progressBarBg = document.createElement("div");
  progressBarBg.className = "progress-bar-bg";

  const content = document.createElement("div");
  content.className = "progress-content";

  const fileName = document.createElement("span");
  fileName.className = "file-name";
  fileName.textContent = file.name;
  fileName.title = file.name;

  const percentageSpan = document.createElement("span");
  percentageSpan.className = "progress-percentage";
  percentageSpan.textContent = "0%";

  content.appendChild(fileName);
  content.appendChild(percentageSpan);
  progressItem.appendChild(progressBarBg);
  progressItem.appendChild(content);

  return {
    element: progressItem,
    progressBar: progressBarBg,
    percentageSpan: percentageSpan
  };
}

// Upload single file with progress using session (sessionId and token in headers)
function uploadFileWithSession(file, progressElements, index, sessionId, token) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open("POST", "/web/upload");
    xhr.setRequestHeader("Content-Type", "application/octet-stream");
    xhr.setRequestHeader("X-File-Name", encodeURIComponent(file.name));
    xhr.setRequestHeader("X-File-Size", file.size.toString());
    xhr.setRequestHeader("X-Session-Id", sessionId);
    xhr.setRequestHeader("X-Upload-Token", token);

    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable) {
        const percent = Math.round((e.loaded / e.total) * 100);
        const progressElement = progressElements[index];

        if (progressElement && progressElement.progressBar) {
          progressElement.progressBar.style.width = `${percent}%`;
        }

        if (progressElement && progressElement.percentageSpan) {
          progressElement.percentageSpan.textContent = `${percent}%`;
        }
      }
    };

    xhr.onload = () => {
      if (xhr.status === 200) {
        resolve();
      } else {
        reject(new Error(`Upload failed with status ${xhr.status}`));
      }
    };

    xhr.onerror = () => {
      reject(new Error("Network error"));
    };

    xhr.send(file);
  });
}

// Start upload process
async function startUpload() {
  if (selectedFiles.length === 0) return;

  // Show loading state
  showLoadingState();

  try {
    // Request upload session from server
    const response = await requestUploadSession();

    if (!response.accepted) {
      // Server refused the upload
      alert(response.message || "Upload request was refused by the server");
      resetToNormalState();
      return;
    }

    // Server accepted - get sessionId and token
    sessionId = response.sessionId;
    uploadToken = response.token;

    // Show session state (removes upload button, shows session info)
    showSessionState(sessionId);

    // Hero transition from upload area to progress container
    heroTransition(uploadArea, progressContainer, async () => {
      progressContainer.innerHTML = "";

      // Create progress items for each file
      const progressElements = [];
      for (let i = 0; i < selectedFiles.length; i++) {
        const file = selectedFiles[i];
        const { element, progressBar, percentageSpan } = createProgressItem(file, i);
        progressContainer.appendChild(element);
        progressElements.push({
          element: element,
          progressBar: progressBar,
          percentageSpan: percentageSpan
        });
      }

      // Upload files one by one
      for (let i = 0; i < selectedFiles.length; i++) {
        const file = selectedFiles[i];
        try {
          await uploadFileWithSession(file, progressElements, i, sessionId, uploadToken);

          const progressItem = progressElements[i].element;
          if (progressItem) {
            progressItem.classList.add('completed');
          }
        } catch (error) {
          console.error(`Failed to upload ${file.name}:`, error);
          const progressItem = progressElements[i].element;
          if (progressItem) {
            progressItem.classList.add('error');
          }
          if (progressElements[i].percentageSpan) {
            progressElements[i].percentageSpan.textContent = "Failed";
          }
        }
      }

      // All uploads complete - reload after a short delay
      setTimeout(() => {
        location.reload();
      }, 1000);
    });

  } catch (error) {
    console.error("Upload request failed:", error);
    alert("Failed to request upload session. Please try again.");
    resetToNormalState();
  }
}

function heroTransition(oldElement, newElement, onComplete) {
  if (oldElement) {
    oldElement.classList.add('hero-exit');
    setTimeout(() => {
      oldElement.style.display = 'none';
      if (newElement) {
        newElement.style.display = 'flex';
        newElement.classList.add('hero-enter');
        setTimeout(() => {
          newElement.classList.remove('hero-enter');
          if (onComplete) onComplete();
        }, 400);
      }
    }, 300);
  } else if (newElement) {
    newElement.style.display = 'flex';
    newElement.classList.add('hero-enter');
    setTimeout(() => {
      newElement.classList.remove('hero-enter');
      if (onComplete) onComplete();
    }, 400);
  }
}

// Event Listeners
dropZone.addEventListener("click", () => {
  if (startUploadBtn.disabled) return;
  fileInput.click();
});

browseButton.addEventListener("click", (e) => {
  e.stopPropagation();
  if (startUploadBtn.disabled) return;
  fileInput.click();
});

fileInput.addEventListener("change", (e) => {
  if (e.target.files.length > 0) {
    addFiles(e.target.files);
  }
});

startUploadBtn.addEventListener("click", startUpload);

// Drag and drop handlers
dropZone.addEventListener("dragover", (e) => {
  e.preventDefault();
  if (!startUploadBtn.disabled) {
    dropZone.classList.add("drag-over");
  }
});

dropZone.addEventListener("dragleave", (e) => {
  e.preventDefault();
  dropZone.classList.remove("drag-over");
});

dropZone.addEventListener("drop", (e) => {
  e.preventDefault();
  dropZone.classList.remove("drag-over");

  if (startUploadBtn.disabled) return;

  const files = e.dataTransfer.files;
  if (files.length > 0) {
    addFiles(files);
  }
});

document.addEventListener("dragover", (e) => {
  e.preventDefault();
});

document.addEventListener("drop", (e) => {
  e.preventDefault();
});