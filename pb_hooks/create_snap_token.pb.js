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

    let res, test1;
    try {
      // Test 1: $http.send GET to jsonplaceholder
      test1 = $http.send({
        url: "https://jsonplaceholder.typicode.com/todos/1",
        method: "GET",
        timeout: 10,
      });

      // Test 2: $http.send POST to Midtrans
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
        body: JSON.stringify({
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
        }),
        timeout: 30,
      });
    } catch (err) {
      return e.json(502, { error: "Gagal terhubung ke Midtrans: " + err.toString() });
    }

    return e.json(200, {
      test1_status: test1.statusCode,
      test1_body: typeof test1.json,
      midtrans_status: res.statusCode,
      midtrans_body: JSON.stringify(res.json),
      midtrans_type: typeof res.json,
    });
  } catch (err) {
    return e.json(500, { error: "Hook error: " + err.toString() });
  }
}, $apis.requireAuth());
