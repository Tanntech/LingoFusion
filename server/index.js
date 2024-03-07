const express = require("express");
const cors = require("cors");
const multer = require("multer");
const fs = require("fs");
const { createClient } = require("@deepgram/sdk");

const app = express();
const PORT = process.env.PORT || 3000;

const deepgram = createClient("980da6e1fc8b36201d08e762b537b863bd914337");

// Enable CORS
app.use(cors());

// Multer setup for file upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  },
});

// File filter function to accept common audio file formats
const fileFilter = function (req, file, cb) {
  console.log("Uploaded file name:", file.originalname);
  if (!file.originalname.match(/\.(mp3|wav|flac|aac|ogg|aiff|m4a|wma)$/i)) {
    return cb(
      new Error(
        "Only MP3, WAV, FLAC, AAC, OGG, AIFF, M4A, and WMA files are allowed!"
      )
    );
  }
  cb(null, true);
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
});

// Endpoint to handle file upload and transcription
app.post("/transcribe", upload.single("audioFile"), async (req, res) => {
  try {
    console.log("File upload request received");
    console.log("Request body:", req.body);
    console.log("Uploaded file:", req.file);

    // Read the uploaded audio file
    const audioData = fs.readFileSync(req.file.path);
    console.log("Audio file read successfully");

    // Transcribe the audio file
    const { result, error } = await deepgram.listen.prerecorded.transcribeFile(
      audioData,
      {
        model: "nova",
      }
    );
    console.log("Transcription result:", result);
    console.log("Transcription error:", error);

    if (error) {
      console.error("Transcription error:", error);
      return res
        .status(400)
        .json({ success: false, error: "Transcription failed" });
    }

    // Extract transcription text from the result
    let transcriptionText = "";
    if (result && result.results && result.results.channels) {
      result.results.channels.forEach((channel) => {
        if (Array.isArray(channel)) {
          channel.forEach((segment) => {
            if (segment.alternatives && segment.alternatives.length > 0) {
              segment.alternatives.forEach((alternative) => {
                transcriptionText += alternative.transcript + " ";
              });
            }
          });
        } else {
          if (channel.alternatives && channel.alternatives.length > 0) {
            channel.alternatives.forEach((alternative) => {
              transcriptionText += alternative.transcript + " ";
            });
          }
        }
      });

      console.log("Transcription text:", transcriptionText); // Log transcription text
    } else {
      console.error("Unexpected structure of transcription result:", result);
      return res
        .status(400)
        .json({ success: false, error: "Unexpected result structure" });
    }

    return res
      .status(200)
      .json({ success: true, transcriptionText: transcriptionText.trim() });
  } catch (error) {
    console.error("Error:", error);
    return res
      .status(500)
      .json({ success: false, error: "Internal server error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
