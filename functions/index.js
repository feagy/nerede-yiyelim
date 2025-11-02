const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const { places } = require("./places.js");
require("dotenv").config();
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;

exports.searchPlaces = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        try {
            const { lat, lng} = req.query;

            if (!lat || !lng) {
                return res.status(400).json({ error: "lat ve lng zorunlu" });
            }
            if (!GOOGLE_API_KEY) {
                return res.status(500).json({ error: "API_KEY eksik" });
            }

            const results = await places.getNearbyPlaces(GOOGLE_API_KEY, lat, lng);

            return res.status(200).json({ places: results });
        } catch (error) {
            console.error(error.response?.data || error.message);
            res.status(500).json({
                error: "Google Places isteği başarısız",
                detail: error.message,
            });
        }
    });
});
         