routerAdd("POST", "/api/create-snap-token", (e) => {
  try {
    const info = e.requestInfo();
    const isAuth = info.auth != null;

    if (!isAuth) {
      return e.json(401, { error: "Unauthorized" });
    }

    const body = info.body;

    const orderId       = body.order_id;
    const amount        = body.amount;
    const customerName  = body.customer_name;
    const customerEmail = body.customer_email;

    if (!orderId || !amount || !customerName || !customerEmail) {
      return e.json(400, {
        error: "Field order_id, amount, customer_name, customer_email wajib diisi",
        received: JSON.stringify(body)
      });
    }

    const serverKey = $os.getenv("MIDTRANS_SERVER_KEY");
    const baseUrl   = $os.getenv("MIDTRANS_BASE_URL");

    if (!serverKey || !baseUrl) {
      return e.json(500, { error: "Konfigurasi Midtrans belum diatur di server" });
    }

    let res;
    try {
      const encoded = serverKey + ":";
      const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
      let encodedAuth = "";
      for (let i = 0; i < encoded.length; i += 3) {
        const b1 = encoded.charCodeAt(i), b2 = encoded.charCodeAt(i + 1) || 0, b3 = encoded.charCodeAt(i + 2) || 0;
        encodedAuth += chars.charAt(b1 >> 2);
        encodedAuth += chars.charAt(((b1 & 3) << 4) | (b2 >> 4));
        encodedAuth += chars.charAt(((b2 & 15) << 2) | (b3 >> 6));
        encodedAuth += chars.charAt(b3 & 63);
      }
      const rem = encoded.length % 3;
      if (rem === 1) encodedAuth = encodedAuth.slice(0, -2) + "==";
      else if (rem === 2) encodedAuth = encodedAuth.slice(0, -1) + "=";
      res = $http.send({
        url: baseUrl,
        method: "POST",
        headers: {
          "Authorization": "Basic " + encodedAuth,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: {
          transaction_details: {
            order_id: orderId,
            gross_amount: parseInt(amount),
          },
          customer_details: {
            first_name: customerName,
            email: customerEmail,
          },
          item_details: [{
            id: "PREMIUM_PLAN",
            price: parseInt(amount),
            quantity: 1,
            name: "UWANGKU Premium",
          }],
          finish_redirect_url: "https://equator-untainted-stank.ngrok-free.dev/payment/finish",
          unfinish_redirect_url: "https://equator-untainted-stank.ngrok-free.dev/payment/unfinish",
          error_redirect_url: "https://equator-untainted-stank.ngrok-free.dev/payment/error",
        },
        timeout: 30,
      });
    } catch (err) {
      return e.json(502, { error: "Gagal terhubung ke Midtrans: " + err.toString() });
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return e.json(200, res.json);
    }

    if (res.statusCode === 401) {
      return e.json(401, { error: "Server key Midtrans tidak valid" });
    }

    let errorMsg = "Terjadi kesalahan";
    try {
      const resJson = res.json;
      errorMsg = (resJson && resJson.status_message) || JSON.stringify(resJson);
    } catch (err2) {}

    return e.json(res.statusCode, { error: errorMsg });
  } catch (err) {
    return e.json(500, { error: "Hook error: " + err.toString() });
  }
}, $apis.requireAuth());
