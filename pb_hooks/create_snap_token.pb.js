// PocketBase hook for creating Midtrans Snap token
// This runs server-side to protect the Midtrans server key
// 
// To enable this hook:
// 1. Place this file in your PocketBase hooks directory
// 2. Set environment variables:
//    - MIDTRANS_SERVER_KEY (your Midtrans server key)
//    - MIDTRANS_BASE_URL (e.g., https://app.sandbox.midtrans.com/snap/v1/transactions)

routerAdd("POST", "/api/create-snap-token", (c) => {
  const body = $apis.requestInfo(c).data;
  const orderId = body.order_id;
  const amount = body.amount;
  const customerName = body.customer_name;
  const customerEmail = body.customer_email;

  if (!orderId || !amount || !customerName || !customerEmail) {
    return c.json(400, { error: "Missing required fields: order_id, amount, customer_name, customer_email" });
  }

  const serverKey = $os.getenv("MIDTRANS_SERVER_KEY");
  const baseUrl = $os.getenv("MIDTRANS_BASE_URL");

  if (!serverKey || !baseUrl) {
    return c.json(500, { error: "Midtrans not configured on server" });
  }

  const credentials = btoa(serverKey + ":");

  const res = $http.send({
    url: baseUrl,
    method: "POST",
    headers: {
      "Authorization": "Basic " + credentials,
      "Content-Type": "application/json",
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
  });

  if (res.statusCode >= 200 && res.statusCode < 300) {
    return c.json(200, res.json());
  }
  
  let errorMsg = "Midtrans error";
  try {
    const resJson = res.json();
    errorMsg = resJson.status_message || JSON.stringify(resJson);
  } catch (e) {}
  
  return c.json(res.statusCode, { error: errorMsg, statusCode: res.statusCode });
}, $apis.requireAdminOrRecordAuth());