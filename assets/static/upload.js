const form = document.getElementById("uploadForm");

form.addEventListener("submit", (e) => {
  e.preventDefault();

  const progressContainer = document.getElementById("progressContainer");

  const fileInput = form.querySelector("input[type='file']");
  const files = fileInput.files;
  if (files.length === 0) return;

  const matches = location.pathname.match(/\/web\/(\d+)/);
  const sessionId = matches ? matches[1] : "";

  let completedUploads = 0;

  const progressElements = [];

  for (let i = 0; i < files.length; i++) {
    const item = document.createElement("div");
    item.className = "progress-item";

    const nameSpan = document.createElement("span");
    nameSpan.className = "file-name";
    nameSpan.textContent = files[i].name;

    const circleContainer = document.createElement("div");
    circleContainer.className = "circular-progress";
    circleContainer.style.setProperty("--progress", "0%");

    const valueSpan = document.createElement("span");
    valueSpan.className = "progress-value";
    valueSpan.textContent = "0%";

    circleContainer.appendChild(valueSpan);
    item.appendChild(nameSpan);
    item.appendChild(circleContainer);
    progressContainer.appendChild(item);

    progressElements.push({ circle: circleContainer, value: valueSpan });
  }

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const xhr = new XMLHttpRequest();
    xhr.open("POST", `/web/${sessionId}`);
    xhr.setRequestHeader("Content-Type", "application/octet-stream");
    xhr.setRequestHeader("X-File-Name", encodeURIComponent(file.name));

    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable) {
        const percent = Math.round((e.loaded / e.total) * 100);
        progressElements[i].circle.style.setProperty("--progress", `${percent}%`);
        progressElements[i].value.textContent = `${percent}%`;
      }
    };

    xhr.onload = () => {
      completedUploads++;
      if (completedUploads === files.length) {
        location.reload();
      }
    };

    xhr.send(file);
  }
});
