
//sunucuda da tutmak gerekirse kullanılacak

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
    const { placeId, userId, placeName, placeAdress, rating, photoUrl } = req.body || {};

    if (!placeId || !userId || !placeName || !placeAdress || !rating || !photoUrl) {
      return res.status(400).json({ error: "Missing fields" });
    }
    await db.collection("favorites").add({
      placeId,
      userId,
      placeName,
      placeAdress,
      rating,
      photoUrl,
    });
    return res.status(200).json({ message: "Favorite added successfully" });
  } catch (error) {
    console.error("addFavorite error:", error);
    return res.status(500).json({ error: "Server error" });
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

app.delete("/deleteFavorite", async (req, res) => {
  try {
    const db = admin.firestore();
    const { favoriteId } = req.body || {};
    if (!favoriteId) {
      return res.status(400).json({ error: "favoriteId is required" });
    }
    await db.collection("favorites").doc(favoriteId).delete();
    return res.status(200).json({ message: "Favorite deleted successfully" });
  } catch (error) {
    console.error("deleteFavorite error:", error);
    return res.status(500).json({ error: "Server error" });
  }
});

module.exports = app;