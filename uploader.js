// uploader.js

// ★ terraform output で表示された api_endpoint の値をここに貼り付けます
const API_BASE_URL = 'https://iube8hqf8h.execute-api.ap-northeast-1.amazonaws.com/'; 

// ★ パスを正しく結合します
const presignedUrlEndpoint = `${API_BASE_URL}generate-presigned-url`; 
const listFilesEndpoint = `${API_BASE_URL}files`;

// --- HTMLの部品（DOM要素）の取得 ---
const fileInput = document.getElementById('fileInput');
const uploadButton = document.getElementById('uploadButton');
const statusMessages = document.getElementById('statusMessages');
const fileListBody = document.getElementById('fileListBody');

let selectedFile = null;

// --- 関数定義 ---
const fetchAndRenderFiles = async () => {
  try {
    statusMessages.textContent = 'ファイルリストを読み込み中...';
    const response = await fetch(listFilesEndpoint);
    if (!response.ok) {
      throw new Error(`(Error ${response.status})`);
    }
    const files = await response.json();
    fileListBody.innerHTML = '';
    if (files.length === 0) {
      fileListBody.innerHTML = '<tr><td colspan="3">アップロードされたファイルはありません。</td></tr>';
    } else {
      files.forEach(file => {
        const row = document.createElement('tr');
        const sizeInKB = (file.fileSize / 1024).toFixed(2);
        const uploadDate = new Date(file.uploadTimestamp).toLocaleString('ja-JP');
        row.innerHTML = `<td>${file.originalFilename}</td><td>${sizeInKB} KB</td><td>${uploadDate}</td>`;
        fileListBody.appendChild(row);
      });
    }
    statusMessages.textContent = 'ファイルを選択してください。';
  } catch (error) {
    console.error('ファイルリスト取得エラー:', error);
    statusMessages.textContent = `リストの読み込みに失敗しました ${error.message}`;
  }
};

const uploadFile = async () => {
  if (!selectedFile) {
    statusMessages.textContent = 'エラー: まずファイルを選択してください。';
    return;
  }
  statusMessages.textContent = 'アップロード準備中...';
  uploadButton.disabled = true;
  uploadButton.setAttribute('aria-busy', 'true');

  try {
    // ステップA: 署名付きURLの取得
    const apiResponse = await fetch(presignedUrlEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        fileName: selectedFile.name,
        contentType: selectedFile.type,
      }),
    });
    if (!apiResponse.ok) {
      const errorText = await apiResponse.text();
      throw new Error(`APIエラー (${apiResponse.status}): ${errorText}`);
    }
    const presignedData = await apiResponse.json();

    // ステップB: S3へファイルアップロード
    statusMessages.textContent = 'S3へファイルをアップロードしています...';
    const s3Response = await fetch(presignedData.uploadUrl, {
      method: 'PUT',
      headers: { 'Content-Type': selectedFile.type },
      body: selectedFile,
    });
    if (!s3Response.ok) {
      throw new Error('S3へのアップロードに失敗しました。');
    }
    statusMessages.textContent = 'アップロード成功！リストを更新します...';

    // アップロード成功後にファイルリストを更新
    await fetchAndRenderFiles();
    fileInput.value = ''; // ファイル選択をリセット
    selectedFile = null;

  } catch (error) {
    console.error('アップロード処理エラー:', error);
    statusMessages.textContent = `エラーが発生しました: ${error.message}`;
  } finally {
    uploadButton.disabled = false;
    uploadButton.setAttribute('aria-busy', 'false');
  }
};

// --- イベントリスナー設定 ---
fileInput.addEventListener('change', () => {
  selectedFile = fileInput.files[0];
  if (selectedFile) {
    statusMessages.textContent = `ファイル選択中: ${selectedFile.name}`;
  }
});
uploadButton.addEventListener('click', uploadFile);

// --- 初期化処理 ---
document.addEventListener('DOMContentLoaded', fetchAndRenderFiles);