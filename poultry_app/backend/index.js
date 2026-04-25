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
  "Content-Type": "application/json",
  "PAYDUNYA-MASTER-KEY": process.env.PAYDUNYA_MASTER_KEY,
  "PAYDUNYA-PRIVATE-KEY": process.env.PAYDUNYA_PRIVATE_KEY,
  "PAYDUNYA-PUBLIC-KEY": process.env.PAYDUNYA_PUBLIC_KEY,
  "PAYDUNYA-TOKEN": process.env.PAYDUNYA_TOKEN,
};

app.get("/", (req, res) => {
  res.json({
    status: "ok",
    app: "PoultryPro Payment Backend",
    paydunyaKeys: {
      masterKeyExists: !!process.env.PAYDUNYA_MASTER_KEY,
      privateKeyExists: !!process.env.PAYDUNYA_PRIVATE_KEY,
      publicKeyExists: !!process.env.PAYDUNYA_PUBLIC_KEY,
      tokenExists: !!process.env.PAYDUNYA_TOKEN,
    },
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

    const response = await axios.post(
      "https://app.paydunya.com/sandbox-api/v1/checkout-invoice/create",
      {
        invoice: {
          total_amount: 2500,
          description: "Abonnement mensuel PoultryPro PRO",
        },
        store: {
          name: "PoultryPro",
        },
        actions: {
          callback_url: "https://gestion-poulailler.onrender.com/paydunya-ipn",
          return_url: "https://gestion-poulailler.onrender.com/payment-success",
          cancel_url: "https://gestion-poulailler.onrender.com/payment-cancel",
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

    if (data.response_code !== "00") {
      return res.status(400).json({
        success: false,
        message: data.response_text || "Erreur PayDunya",
        raw: data,
      });
    }

    return res.json({
      success: true,
      url: data.response_text,
      raw: data,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Erreur création paiement",
      error: error.response?.data || error.message,
    });
  }
});

app.get("/payment-success", (req, res) => {
  res.send("Paiement reçu. Vous pouvez retourner dans PoultryPro.");
});

app.get("/payment-cancel", (req, res) => {
  res.send("Paiement annulé.");
});

app.post("/paydunya-ipn", async (req, res) => {
  try {
    if (!db) {
      return res.status(200).send("OK WITHOUT FIRESTORE");
    }

    const data = req.body;
    const status = data.status || data.data?.status;
    const customData = data.custom_data || data.data?.custom_data || {};
    const userId = customData.userId;

    if (status === "completed" || status === "success" || status === "paid") {
      if (!userId) return res.status(400).send("userId manquant");

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
    }

    return res.status(200).send("OK");
  } catch (error) {
    return res.status(500).send("Erreur IPN");
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`PoultryPro backend running on port ${PORT}`);
});