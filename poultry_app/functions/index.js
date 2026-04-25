const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// 🔹 1. CREER PAIEMENT
exports.createPayment = functions.https.onRequest(async (req, res) => {
  try {
    const { amount, userId } = req.body;

    const response = await axios.post(
      "https://app.paydunya.com/api/v1/checkout-invoice/create",
      {
        invoice: {
          total_amount: amount,
          description: "Abonnement PoultryPro"
        },
        store: {
          name: "PoultryPro"
        },
        custom_data: {
          userId: userId
        }
      },
      {
        headers: {
          "PAYDUNYA-MASTER-KEY": "**************************",
          "PAYDUNYA-PRIVATE-KEY": "**************************",
          "PAYDUNYA-PUBLIC-KEY": "**************************",
          "PAYDUNYA-TOKEN": "**************************"
        }
      }
    );

    res.send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).send(error.message);
  }
});

// 🔥 2. WEBHOOK → ACTIVE PRO
exports.paydunyaWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const data = req.body;

    if (data.status === "completed" || data.status === "success") {
      const userId = data.custom_data?.userId;

      if (!userId) {
        return res.status(400).send("userId manquant");
      }

      const now = new Date();

      const expireDate = new Date();
      expireDate.setDate(now.getDate() + 30);

      await db.collection("subscriptions").doc(userId).set({
        plan: "pro",
        status: "active",
        startDate: now,
        expireAt: expireDate
      });

      console.log("PRO activé pour :", userId);
    }

    res.send("OK");
  } catch (error) {
    console.error(error);
    res.status(500).send("Erreur webhook");
  }
});