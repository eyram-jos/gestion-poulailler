const express = require("express");
const axios = require("axios");
const cors = require("cors");
const admin = require("firebase-admin");

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

const PORT = process.env.PORT || 3000;

if (!admin.apps.length) {
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;

  if (!serviceAccountJson) {
    console.warn("FIREBASE_SERVICE_ACCOUNT missing. Firestore webhook will not work.");
  } else {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
    });
  }
}

const db = admin.apps.length ? admin.firestore() : null;

const PAYDUNYA_HEADERS = {
  "PAYDUNYA-MASTER-KEY": process.env.PAYDUNYA_MASTER_KEY,
  "PAYDUNYA-PRIVATE-KEY": process.env.PAYDUNYA_PRIVATE_KEY,
  "PAYDUNYA-PUBLIC-KEY": process.env.PAYDUNYA_PUBLIC_KEY,
  "PAYDUNYA-TOKEN": process.env.PAYDUNYA_TOKEN,
};

app.get("/", (req, res) => {
  res.json({
    status: "ok",
    app: "PoultryPro Payment Backend",
  });
});

app.post("/create-payment", async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId manquant",
      });
    }

    const amount = 2500;

    const response = await axios.post(
      "https://app.paydunya.com/api/v1/checkout-invoice/create",
      {
        invoice: {
          total_amount: amount,
          description: "Abonnement mensuel PoultryPro PRO",
        },
        store: {
          name: "PoultryPro",
        },
        custom_data: {
          userId: userId,
          plan: "pro",
          durationDays: 30,
        },
      },
      {
        headers: PAYDUNYA_HEADERS,
      }
    );

    const data = response.data;

    const paymentUrl =
      data.response_text ||
      data.response_url ||
      data.url ||
      null;

    if (!paymentUrl) {
      return res.status(500).json({
        success: false,
        message: "Lien PayDunya introuvable",
        raw: data,
      });
    }

    return res.json({
      success: true,
      url: paymentUrl,
      raw: data,
    });
  } catch (error) {
    console.error("CREATE PAYMENT ERROR:", error.response?.data || error.message);

    return res.status(500).json({
      success: false,
      message: "Erreur creation paiement",
      error: error.response?.data || error.message,
    });
  }
});

app.post("/paydunya-ipn", async (req, res) => {
  try {
    if (!db) {
      return res.status(500).send("Firestore non configure");
    }

    const data = req.body;
    console.log("IPN PAYDUNYA:", JSON.stringify(data));

    const status = data.status || data.data?.status;
    const customData = data.custom_data || data.data?.custom_data || {};
    const userId = customData.userId;

    if (status === "completed" || status === "success" || status === "paid") {
      if (!userId) {
        return res.status(400).send("userId manquant");
      }

      const now = new Date();
      const expireAt = new Date();
      expireAt.setDate(now.getDate() + 30);

      await db.collection("subscriptions").doc(userId).set(
        {
          plan: "pro",
          status: "active",
          startDate: now,
          expireAt: expireAt,
          lastPaymentProvider: "paydunya",
          lastPaymentAt: now,
          amount: 2500,
        },
        { merge: true }
      );

      console.log("PRO active pour:", userId);
    }

    return res.status(200).send("OK");
  } catch (error) {
    console.error("IPN ERROR:", error);
    return res.status(500).send("Erreur IPN");
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`PoultryPro backend running on port ${PORT}`);
});