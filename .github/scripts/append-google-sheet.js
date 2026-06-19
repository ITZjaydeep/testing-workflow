#!/usr/bin/env node

const { google } = require("googleapis");

async function main() {
  const required = [
    "GOOGLE_SERVICE_ACCOUNT",
    "GOOGLE_SHEET_ID",
    "VERSION_NAME",
    "VERSION_CODE",
    "RELEASE_NOTES",
  ];

  for (const key of required) {
    if (!process.env[key]) {
      throw new Error(`${key} is missing`);
    }
  }

  const serviceAccount = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT);

  const auth = new google.auth.GoogleAuth({
    credentials: serviceAccount,
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });

  const sheets = google.sheets({
    version: "v4",
    auth,
  });

  const spreadsheetId = process.env.GOOGLE_SHEET_ID;
  const sheetName = "Releases";

  const versionName = process.env.VERSION_NAME;
  const versionCode = process.env.VERSION_CODE;
  const releaseNotes = process.env.RELEASE_NOTES;
  const playStoreLink = process.env.PLAY_STORE_LINK || "";

  const repository = process.env.GITHUB_REPOSITORY;
  const actor = process.env.GITHUB_ACTOR;
  const branch = process.env.GITHUB_REF_NAME;
  const commit = process.env.GITHUB_SHA;
  const workflowRunId = process.env.GITHUB_RUN_ID;
  const serverUrl = process.env.GITHUB_SERVER_URL;

  const tag = `android-v${versionName}-${versionCode}`;

  const workflowUrl =
    `${serverUrl}/${repository}/actions/runs/${workflowRunId}`;

  const commitUrl =
    `${serverUrl}/${repository}/commit/${commit}`;

  const releaseUrl =
    `${serverUrl}/${repository}/releases/tag/${tag}`;

  const date = new Date().toISOString();

  // Check if sheet already has headers
  const existing = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `${sheetName}!A1:A1`,
  });

  if (!existing.data.values || existing.data.values.length === 0) {
    console.log("Creating header row...");

    await sheets.spreadsheets.values.update({
      spreadsheetId,
      range: `${sheetName}!A1`,
      valueInputOption: "RAW",
      requestBody: {
        values: [[
          "Date",
          "Version Name",
          "Version Code",
          "Tag",
          "Branch",
          "Actor",
          "Commit",
          "Release Notes",
          "GitHub Release",
          "Workflow",
          "Commit URL",
          "Play Testing Link"
        ]]
      }
    });
  }

  console.log("Appending release...");

  await sheets.spreadsheets.values.append({
    spreadsheetId,
    range: `${sheetName}!A:L`,
    valueInputOption: "RAW",
    insertDataOption: "INSERT_ROWS",
    requestBody: {
      values: [[
        date,
        versionName,
        versionCode,
        tag,
        branch,
        actor,
        commit,
        releaseNotes,
        releaseUrl,
        workflowUrl,
        commitUrl,
        playStoreLink
      ]]
    }
  });

  console.log("==================================");
  console.log("Google Sheet updated successfully");
  console.log("==================================");
  console.log(`Version : ${versionName}`);
  console.log(`Build   : ${versionCode}`);
  console.log(`Tag     : ${tag}`);
}

main().catch((err) => {
  console.error("");
  console.error("Google Sheets update failed");
  console.error(err);

  process.exit(1);
});