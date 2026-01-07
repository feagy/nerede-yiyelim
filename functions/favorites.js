const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const app = express();

app.use(cors({ origin: true }));
app.options("*", cors({ origin: true }));
app.use(express.json());

app.post("/addFavorite", async (req, res) => {
  try {
    const db = admin.firestore();
    const { placeId, userId, placeName, placeAddress, rating, photoUrl } = req.body || {};

    if (!placeId || !userId || !placeName || !placeAddress || !rating || !photoUrl) {
      return res.status(400).json({ error: "Missing fields" });
    }

    const favoriteId = `${placeId}_${userId}`;
    const ref = db.collection("favorites").doc(favoriteId);

    await ref.create({
      placeId,
      userId,
      placeName,
      placeAddress,
      rating,
      photoUrl,
    });
    return res.status(200).json({ message: "Favorite added successfully" });
  } catch (error) {
    if (error?.code === 6) {
      return res.status(409).json({ error: "Favorite already exists" });
    }
    console.error("addFavorite error:", error);
    return res.status(500).json({ error: "Server error", details: String(error) });
  }
});

app.get("/readFavorites", async (req, res) => {
  try {
    const db = admin.firestore();
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }
    
    const snap = await db
      .collection("favorites")
      .where("userId", "==", String(userId))
      .get();
    const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.status(200).json({ ok: true, items });
  } catch (e) {
    console.error("get favorites error:", e);
    return res.status(500).json({ error: String(e) });
  }
});

app.delete("/deleteFavorite/:favoriteId", async (req, res) => {
  try {
    const db = admin.firestore();
    const { favoriteId } = req.params;
    if (!favoriteId) {
      return res.status(400).json({ error: "favoriteId is required" });
    }
    
    const ref  = db.collection("favorites").doc(favoriteId);
    const snap = await ref.get();

    if (!snap.exists) {
      return res.status(404).json({ error: "Favorite not found" });
    }

    await ref.delete();
    return res.status(200).json({ message: "Favorite deleted successfully" });
  } catch (error) {
    console.error("deleteFavorite error:", error);
    return res.status(500).json({ error: "Server error", details: String(error) });
  }
});

module.exports = app;