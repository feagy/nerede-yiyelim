const axios = require("axios");
module.exports.places = {
    getNearbyPlaces,
};
async function getNearbyPlaces(API_KEY, lat, lng, radius = 50000, maxCount = 20) {
    const url = "https://places.googleapis.com/v1/places:searchNearby";
    const body = {
        languageCode: "tr",
        regionCode: "TR",
        includedPrimaryTypes: ["restaurant"],
        maxResultCount: parseInt(maxCount),
        rankPreference: "DISTANCE", // veya POPULARITY
        locationRestriction: {
          circle: {
            center: { latitude: lat, longitude: lng },
            radius: parseFloat(radius),
          },
        },
    };

    const headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": API_KEY,
      "X-Goog-FieldMask":
      "places.displayName,places.formattedAddress,places.location,places.rating,places.primaryTypeDisplayName",
    };

    const response = await axios.post(url, body, { headers });
    const places = response.data.places?.map((p) => ({
        name: p.displayName?.text || "Ad Yok",
        address: p.formattedAddress || "Adres Yok",
        rating: p.rating || null,
        type: p.primaryTypeDisplayName?.text || "",
        lat: p.location?.latitude,
        lng: p.location?.longitude,
    }));
    return places || [];

}

