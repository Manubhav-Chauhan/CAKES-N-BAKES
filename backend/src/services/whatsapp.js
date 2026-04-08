const DEFAULT_BUSINESS_NAME = "Cakes n Bakes 365";
const currency = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 0
});

const STATUS_LABELS = {
  placed: "placed",
  confirmed: "confirmed",
  preparing: "being prepared",
  out_for_delivery: "out for delivery",
  ready_for_pickup: "ready for pickup",
  delivered: "delivered",
  cancelled: "cancelled"
};

const isWhatsAppEnabled = () => {
  if (process.env.WHATSAPP_ENABLED === "false") {
    return false;
  }
  return Boolean(
    process.env.WHATSAPP_ACCOUNT_SID &&
      process.env.WHATSAPP_AUTH_TOKEN &&
      process.env.WHATSAPP_FROM
  );
};

const normalizePhone = (input) => {
  if (!input) return null;
  let value = String(input).trim();
  if (!value) return null;

  if (value.startsWith("whatsapp:")) {
    value = value.slice("whatsapp:".length);
  }

  value = value.replace(/[^\d+]/g, "");
  if (!value) return null;

  if (value.startsWith("+")) {
    return value;
  }

  const countryCode = process.env.WHATSAPP_DEFAULT_COUNTRY_CODE;
  if (!countryCode) return null;
  const prefix = countryCode.startsWith("+") ? countryCode : `+${countryCode}`;
  return `${prefix}${value}`;
};

const buildWhatsAppTo = (phone) => {
  const normalized = normalizePhone(phone);
  if (!normalized) return null;
  return `whatsapp:${normalized}`;
};

const formatStatusLabel = (status) => STATUS_LABELS[status] || status;

const formatOrderStatusMessage = ({ orderId, status, customerName }) => {
  const label = formatStatusLabel(status);
  const businessName =
    process.env.WHATSAPP_BUSINESS_NAME || DEFAULT_BUSINESS_NAME;
  const greeting = customerName ? `Hi ${customerName},` : "Hi,";

  return `${greeting} your ${businessName} order #${orderId} is ${label}. Reply STATUS ${orderId} anytime for updates.`;
};

const formatHelpMessage = () => {
  const businessName =
    process.env.WHATSAPP_BUSINESS_NAME || DEFAULT_BUSINESS_NAME;
  return `Welcome to ${businessName}! Send STATUS <order id> to get the latest update. Example: STATUS 1024.`;
};

const getAdminAlertWhatsAppNumber = () =>
  String(
    process.env.ADMIN_WHATSAPP_NUMBER || process.env.WHATSAPP_NUMBER || ""
  ).trim();

const formatItemQuantity = (item) => {
  const quantity = Number(item.quantity);

  if (item.unitType === "kg") {
    return `${quantity} kg`;
  }

  if (item.unitType === "piece") {
    return `${quantity} pc${quantity > 1 ? "s" : ""}`;
  }

  return `${quantity}`;
};

const formatItemRate = (item) => {
  const unitPrice = currency.format(Number(item.unitPrice));

  if (item.unitType === "kg") return `${unitPrice}/kg`;
  if (item.unitType === "piece") return `${unitPrice}/pc`;
  return unitPrice;
};

const formatAdminOrderAlertMessage = ({
  orderId,
  customerName,
  phone,
  address,
  notes,
  whatsappOptIn,
  items,
  totals
}) => {
  const businessName =
    process.env.WHATSAPP_BUSINESS_NAME || DEFAULT_BUSINESS_NAME;
  const lines = [
    `New order at ${businessName}`,
    `Order #${orderId}`,
    "",
    `Customer: ${customerName}`,
    `Phone: ${phone}`,
    `Address: ${address || "Not provided"}`,
    `WhatsApp updates: ${whatsappOptIn ? "Yes" : "No"}`,
    `Notes: ${notes || "-"}`,
    "",
    "Items:"
  ];

  items.forEach((item) => {
    lines.push(
      `- ${item.name}: ${formatItemQuantity(item)} x ${formatItemRate(item)} = ${currency.format(Number(item.lineTotal))}`
    );
  });

  lines.push("");
  lines.push(`Subtotal: ${currency.format(Number(totals.subtotal || 0))}`);
  lines.push(`Tax: ${currency.format(Number(totals.tax || 0))}`);
  lines.push(`Total: ${currency.format(Number(totals.total || 0))}`);

  return lines.join("\n");
};

const escapeXml = (value) =>
  String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");

const buildTwimlMessage = (message) => `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Message>${escapeXml(message)}</Message>
</Response>`;

const sendWhatsAppMessage = async ({ to, body }) => {
  if (!isWhatsAppEnabled()) {
    return { skipped: true, reason: "not_configured" };
  }

  const toNumber = buildWhatsAppTo(to);
  if (!toNumber) {
    return { skipped: true, reason: "invalid_phone" };
  }

  const accountSid = process.env.WHATSAPP_ACCOUNT_SID;
  const authToken = process.env.WHATSAPP_AUTH_TOKEN;
  const from = process.env.WHATSAPP_FROM;

  const payload = new URLSearchParams({
    To: toNumber,
    From: from,
    Body: body
  }).toString();

  const response = await fetch(
    `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
    {
      method: "POST",
      headers: {
        Authorization: `Basic ${Buffer.from(
          `${accountSid}:${authToken}`
        ).toString("base64")}`,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: payload
    }
  );

  if (!response.ok) {
    const text = await response.text();
    throw new Error(
      `Twilio send failed (${response.status}): ${text || "unknown error"}`
    );
  }

  const data = await response.json();
  return { skipped: false, sid: data.sid };
};

module.exports = {
  buildTwimlMessage,
  buildWhatsAppTo,
  formatAdminOrderAlertMessage,
  formatHelpMessage,
  formatOrderStatusMessage,
  formatStatusLabel,
  getAdminAlertWhatsAppNumber,
  isWhatsAppEnabled,
  normalizePhone,
  sendWhatsAppMessage
};
