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
    const { placeId, userId, rating, comment, placeName, placeAddress } = req.body;

    if (!placeId || !userId || rating == null || !comment || !placeName || !placeAddress) {
      return res.status(400).json({ error: "Missing fields" });
    }

    const reviewId = `${placeId}_${userId}`;
    const ref = db.collection("reviews").doc(reviewId);

    await ref.create({
      placeId,
      userId,
      rating,
      comment,
      placeName,
      placeAddress,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return res.status(201).json({ message: "Review created" });
  } catch (err) {
    if (err?.code === 6) {
      return res.status(409).json({ error: "Review already exists" });
    }
    console.error("addReview error:", err);
    return res.status(500).json({ error: "Server error" });
  }
});

app.put("/updateReview", async (req, res) => {
  try {
    const db = admin.firestore();
    const { placeId, userId, rating, comment } = req.body;

    if (!placeId || !userId || rating == null || !comment) {
      return res.status(400).json({ error: "Missing fields" });
    }

    const reviewId = `${placeId}_${userId}`;
    const ref = db.collection("reviews").doc(reviewId);

    const snap = await ref.get();
    if (!snap.exists) {
      return res.status(404).json({ error: "Review not found" });
    }

    await ref.update({
      rating,
      comment,
      updatedAt: FieldValue.serverTimestamp(),
    });

    return res.status(200).json({ message: "Review updated" });
  } catch (err) {
    console.error("updateReview error:", err);
    return res.status(500).json({ error: err.message ?? String(err) });
  }
});

app.get("/readReviews", async (req, res) => {
  try {
    const db = admin.firestore();
    const { placeId, limit = 20, cursor } = req.query;

    if (!placeId) {
      return res.status(400).json({ error: "placeId is required" });
    }

    const lim = Math.min(parseInt(limit, 10) || 20, 50);

    let q = db  
      .collection("reviews")
      .where("placeId", "==", String(placeId))
      .orderBy("createdAt", "desc")
      .limit(lim);

    if (cursor) {
      const lastDoc = await db.collection("reviews").doc(String(cursor)).get();
      if (lastDoc.exists) {
        q = q.startAfter(lastDoc);
      } else {
        return res.status(400).json({ error: "Invalid cursor" });
      }
    }

    const snap = await q.get();

    const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    const nextCursor = snap.docs.length ? snap.docs[snap.docs.length - 1].id : null;

    return res.status(200).json({
      ok: true,
      items,
      nextCursor,          
      hasMore: items.length === lim,
    });
  } catch (e) {
    console.error("get reviews error:", e);
    return res.status(500).json({ error: String(e) });
  }
});

app.delete("/deleteReview/:reviewId", async (req, res) => {
  try {
    const db = admin.firestore();
    const { reviewId } = req.params;

    if (!reviewId) {
      return res.status(400).json({ error: "reviewId is required" });
    }

    const ref = db.collection("reviews").doc(reviewId);
    const snap = await ref.get();

    if (!snap.exists) {
      return res.status(404).json({ error: "Review not found" });
    }

    await ref.delete();
    return res.status(200).json({ message: "Review deleted successfully" });
  } catch (error) {
    console.error("deleteReview error:", error);
    return res.status(500).json({ error: "Server error", details: String(error) });
  }
});

app.get("/getAverageRating", async (req, res) => {
  try {
    const db = admin.firestore();
    const { placeId } = req.query;
    if (!placeId) {
      return res.status(400).json({ error: "placeId is required" });
    }
    const snap = await db
      .collection("reviews")
      .where("placeId", "==", String(placeId))
      .get();

    let totalRating = 0;
    let count = 0;
    snap.forEach(doc => {
      const data = doc.data();
      if (data.rating != null) {
        totalRating += data.rating;
        count++;
      }
    });

    const averageRating = count > 0 ? parseFloat((totalRating / count).toFixed(2)) : 0;
    return res.status(200).json({ ok: true, averageRating });
  } catch (e) {
    console.error("get average rating error:", e);
    return res.status(500).json({ error: String(e) });
  }
});

module.exports = app;