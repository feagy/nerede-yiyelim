const axios = require("axios");
module.exports.places = {
    getNearbyPlaces,
    getPlacePhoto,
    getNearbyPlacesText,
    generateReviewSummary,
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

async function generateReviewSummary(LLM_URL, reviews, model="qwen2.5:7b-instruct") {
    const payload = {
        model: model,
        stream: false,
        messages: [
            { 
              role: "system", 
              content: `
                Sen restoran yorumlarını özetleyen bir asistansın. Kullanıcıdan gelen yorumları analiz edip kısa ve öz bir şekilde artılarını ve eksilerini belirtmelisin.
                Kurallar:
                - Cevabı SADECE Türkçe yaz.
                - Çıktıda sadece bir paragraflık çok uzun olmayan genel bir özet yap.
                - İncelemelerde belirtilmişse sevilen yemeklerden/içeceklerden bahset.
                - Yorumlarda geçmeyen bilgi uydurma; kesin konuşma (ör. "kesinlikle") kullanma.
                - Tutarlı bir dil kullan.
                - Tekrar etme, çok uzatma.
                - Kibar ve profesyonel ol.
                - Eğerki yorum sayısı az ve genel bir değerlendirme yapmak mümkün değilse şu mesajı ver: "Yorum sayısı yetersiz olduğu için genel bir değerlendirme yapılamıyor.".
                - Anlamadığın ve muğlak yerleri özete dahil etme.
                - Yorumlarda bahsedilen spesifik isimleri (mekan, kişi, yemek vs.) kullanma.
                - Yorumlarda verilen önerilerden bahsetme.
                - Sadece mekanın kalitesi hakkında yapılandırılmış bir özet yap.
                `
            },
            { 
              role: "user", 
              content: `Yorumlar:\n- ${reviews.map(r => r.trim()).join("\n- ")}` 
            }
        ],
        options: { temperature: 0.3 }
    };

    const response = await axios.post(LLM_URL, payload, {
        headers: { "Content-Type": "application/json" },
        timeout: 120000,
    });

    return response.data?.message?.content || "Yorum özeti oluşturulamadı.";
  }
