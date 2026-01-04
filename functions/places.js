const axios = require("axios");
module.exports.places = {
    getNearbyPlaces,
    getPlacePhoto,
    getNearbyPlacesText,
};
async function getNearbyPlaces(API_KEY, lat, lng, radius, maxCount = 20) {
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
      "X-Goog-FieldMask": `places.id,
                           places.displayName,
                           places.internationalPhoneNumber,
                           places.formattedAddress,
                           places.regularOpeningHours,
                           places.location,
                           places.rating,
                           places.userRatingCount,
                           places.reviews,
                           places.primaryTypeDisplayName,
                           places.googleMapsUri,
                           places.googleMapsLinks,
                           places.photos`.replace(/\s+/g, ""),
    };

    const response = await axios.post(url, body, { headers });
    const places = response.data.places?.map((p) => ({
        distance: getDistanceInKm(lat, lng, p.location?.latitude, p.location?.longitude),
        id: p.id,
        name: p.displayName?.text || "Ad Yok",
        phone: p.internationalPhoneNumber || "Telefon Yok",
        address: p.formattedAddress || "Adres Yok",
        openingHours: p.regularOpeningHours || null,
        rating: p.rating || null,
        userRatingCount: p.userRatingCount || null,
        reviews: p.reviews?.map((r) => ({
          name: r.authorAttribution?.displayName || "Yazar Yok",
          text: r.originalText?.text || "Yorum Yok",
          rating: r.rating || 0,
        })) ||null,
        type: p.primaryTypeDisplayName?.text || "",
        lat: p.location?.latitude,
        lng: p.location?.longitude,
        googleMapsUri: p.googleMapsUri || null,
        googleMapsLinks: p.googleMapsLinks || null,
        photos: p.photos?.map((ph) => ({
          photoName: ph.name,
        })) || null,
    }));
    return places || [];
}

async function getNearbyPlacesText(API_KEY, textQuery, lat, lng, radius, maxCount = 20) {
    const url = "https://places.googleapis.com/v1/places:searchText";
    const body = {
        textQuery: textQuery,
        languageCode: "tr",
        regionCode: "TR",
        //includedType: "restaurant",
        maxResultCount: parseInt(maxCount),
        rankPreference: "DISTANCE", // veya RELEVANCE
        locationBias: {
          circle: {
            center: { latitude: lat, longitude: lng },
            radius: parseFloat(radius),
          },
        },
    };

    const headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": API_KEY,
      "X-Goog-FieldMask": `places.id,
                           places.displayName,
                           places.internationalPhoneNumber,
                           places.formattedAddress,
                           places.regularOpeningHours,
                           places.location,
                           places.rating,
                           places.userRatingCount,
                           places.reviews,
                           places.primaryTypeDisplayName,
                           places.photos`.replace(/\s+/g, ""),
    };

    const response = await axios.post(url, body, { headers });
    const places = response.data.places?.map((p) => ({
        distance: getDistanceInKm(lat, lng, p.location?.latitude, p.location?.longitude),
        id: p.id,
        name: p.displayName?.text || "Ad Yok",
        phone: p.internationalPhoneNumber || "Telefon Yok",
        address: p.formattedAddress || "Adres Yok",
        openingHours: p.regularOpeningHours || null,
        rating: p.rating || null,
        userRatingCount: p.userRatingCount || null,
        reviews: p.reviews?.map((r) => ({
          name: r.authorAttribution?.displayName || "Yazar Yok",
          text: r.originalText?.text || "Yorum Yok",
          rating: r.rating || 0,
        })) ||null,
        type: p.primaryTypeDisplayName?.text || "",
        lat: p.location?.latitude,
        lng: p.location?.longitude,
        photoName: p.photos?.[0]?.name || null,
    }));
    return places || [];
}
function getDistanceInKm(lat1, lng1, lat2, lng2) {
  const R = 6371; // km
  const toRad = (deg) => deg * Math.PI / 180;

  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
    Math.cos(toRad(lat2)) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

async function getPlacePhoto(API_KEY, photoName, maxWidth) {
    const url = `https://places.googleapis.com/v1/${photoName}/media?maxWidthPx=${maxWidth}&key=${API_KEY}`;
    const response = await axios.get(url, { responseType: "arraybuffer" });
    return response.data;
}

