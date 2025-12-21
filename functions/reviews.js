const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const app = express();

app.use(cors({ origin: true }));
app.options("*", cors({ origin: true }));
app.use(express.json());

app.post("/addReview", async (req, res) => {
  try {
    const db = admin.firestore(); 

    const { placeId, userId, rating, comment } = req.body || {};

    if (!placeId || !userId || rating == null || !comment) {
      return res.status(400).json({ error: "Missing fields" });
    }

    await db.collection("reviews").add({
      placeId,
      userId,
      rating,
      comment,
      createdAt: FieldValue.serverTimestamp(),
    });

    return res.status(200).json({ message: "Review added successfully" });
  } catch (error) {
    console.error("addReview error:", error);
    return res.status(500).json({ error: "Server error" });
  }
});

app.get("/readReviews", async (req, res) => {
  try {
    const db = admin.firestore();
    const { placeId, limit = 20 } = req.query;

    if (!placeId) {
      return res.status(400).json({ error: "placeId is required" });
    }

    const lim = Math.min(parseInt(limit, 10) || 20, 50);

    const snap = await db
      .collection("reviews")
      .where("placeId", "==", String(placeId))
      .orderBy("createdAt", "desc")
      .limit(lim)
      .get();

    const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.status(200).json({ ok: true, items });
  } catch (e) {
    console.error("get reviews error:", e);
    return res.status(500).json({ error: String(e) });
  }
});



module.exports = app;