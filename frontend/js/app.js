const API_BASE = window.__APP_CONFIG__?.API_BASE || "http://localhost:4000/api";
const WHATSAPP_NUMBER = window.__APP_CONFIG__?.WHATSAPP_NUMBER || "";
const ADMIN_TOKEN_KEY = "cb365_admin_token";
const ADMIN_ORDER_STATUSES = [
  "placed",
  "confirmed",
  "preparing",
  "ready_for_pickup",
  "out_for_delivery",
  "delivered",
  "cancelled"
];
const FALLBACK_IMAGE =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='600' height='400'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0' y1='0' x2='1' y2='1'%3E%3Cstop offset='0%25' stop-color='%23f6c9b3'/%3E%3Cstop offset='100%25' stop-color='%23f8f1e9'/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect width='600' height='400' fill='url(%23g)'/%3E%3Ctext x='50%25' y='50%25' dominant-baseline='middle' text-anchor='middle' font-family='Manrope, sans-serif' font-size='32' fill='%236f4e37'%3ECakes%20n%20Bakes%20365%3C/text%3E%3C/svg%3E";

const state = {
  categories: [],
  activeCategory: "All",
  menuCache: {},
  cart: {
    items: [],
    totals: { subtotal: 0, tax: 0, total: 0 }
  },
  admin: {
    token: localStorage.getItem(ADMIN_TOKEN_KEY) || ""
  }
};

const currency = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 0
});

const sessionKey = "cb365_session";

const getSessionId = () => {
  let id = localStorage.getItem(sessionKey);
  if (!id) {
    id = `cb365-${Math.random().toString(36).slice(2, 10)}`;
    localStorage.setItem(sessionKey, id);
  }
  return id;
};

const sessionId = getSessionId();

const qs = (selector) => document.querySelector(selector);
const qsa = (selector) => Array.from(document.querySelectorAll(selector));

const sanitizeWhatsAppNumber = (value) =>
  String(value || "").replace(/\D/g, "");

const buildWhatsAppLink = (message) => {
  const digits = sanitizeWhatsAppNumber(WHATSAPP_NUMBER);
  if (!digits) return null;
  const base = `https://wa.me/${digits}`;
  if (!message) return base;
  return `${base}?text=${encodeURIComponent(message)}`;
};

const toast = (message) => {
  const el = qs("#toast");
  if (!el) return;
  el.textContent = message;
  el.classList.add("show");
  window.clearTimeout(el.dataset.timer);
  const timer = window.setTimeout(() => el.classList.remove("show"), 2200);
  el.dataset.timer = timer;
};

const setActiveNav = (page) => {
  qsa(".nav-links a").forEach((link) => {
    const target = link.getAttribute("href")?.replace("#", "");
    link.classList.toggle("active", target === page);
  });
};

const setActivePage = (page) => {
  qsa(".page").forEach((section) => {
    section.classList.toggle("active", section.dataset.page === page);
  });
  setActiveNav(page);
  window.scrollTo({ top: 0, behavior: "smooth" });

  if (page === "cart" || page === "checkout") {
    refreshCart();
  }

  if (page === "admin") {
    loadAdminDashboard();
  }
};

const resolveRoutablePage = (requestedPage) => {
  const normalized = String(requestedPage || "").trim() || "home";
  const availablePages = qsa(".page")
    .map((section) => section.dataset.page)
    .filter(Boolean);

  if (!availablePages.length) return "home";
  return availablePages.includes(normalized) ? normalized : "home";
};

const handleRouting = () => {
  const requestedPage = window.location.hash.replace("#", "");
  const page = resolveRoutablePage(requestedPage);

  if (requestedPage && requestedPage !== page) {
    window.location.hash = `#${page}`;
    return;
  }

  setActivePage(page);
};

const request = async (endpoint, options = {}) => {
  const { headers = {}, ...rest } = options;
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      "Content-Type": "application/json",
      ...headers
    },
    ...rest
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({
      error: { message: "Unexpected error" }
    }));
    throw new Error(error.error?.message || "Unexpected error");
  }

  return response.json();
};

const loadCategories = async () => {
  try {
    const result = await request("/categories");
    state.categories = result.data;
  } catch (error) {
    state.categories = [
      { id: 1, name: "Bakery" },
      { id: 2, name: "Fast Food" },
      { id: 3, name: "Snacks" },
      { id: 4, name: "Drinks" }
    ];
  }

  renderCategoryTabs();
};

const renderCategoryTabs = () => {
  const container = qs("#category-tabs");
  if (!container) return;

  const categories = ["All", ...state.categories.map((c) => c.name)];
  container.innerHTML = "";

  categories.forEach((name) => {
    const button = document.createElement("button");
    button.textContent = name;
    button.classList.toggle("active", name === state.activeCategory);
    button.addEventListener("click", () => {
      state.activeCategory = name;
      renderCategoryTabs();
      loadMenu(name);
    });
    container.appendChild(button);
  });
};

const loadMenu = async (category) => {
  const menuState = qs("#menu-state");
  if (menuState) menuState.textContent = "Loading menu...";

  const key = category && category !== "All" ? category : "all";

  if (state.menuCache[key]) {
    renderMenu(state.menuCache[key]);
    if (menuState) menuState.textContent = "";
    return;
  }

  try {
    const query = category && category !== "All" ? `?category=${encodeURIComponent(category)}` : "";
    const result = await request(`/menu${query}`);
    state.menuCache[key] = result.data;
    renderMenu(result.data);
    if (menuState) menuState.textContent = "";
  } catch (error) {
    if (menuState) {
      menuState.textContent = `Unable to load menu: ${error.message}`;
    }
  }
};

const getUnitLabel = (unitType) => {
  if (unitType === "kg") return "/kg";
  if (unitType === "piece") return "/piece";
  return "";
};

const CAKE_WEIGHT_OPTIONS = [0.5, 1, 1.5, 2, 2.5, 3];
const PASTRY_PIECE_OPTIONS = [1, 2, 3, 4, 5, 6, 8, 10];
const HALF_PORTION_SUFFIX = " (Half)";

const stripHalfPortionSuffix = (name) =>
  String(name || "").endsWith(HALF_PORTION_SUFFIX)
    ? String(name).slice(0, -HALF_PORTION_SUFFIX.length)
    : String(name || "");

const getMenuDisplayItems = (items) => {
  const groups = new Map();

  items.forEach((item) => {
    if (item.unit_type !== "item") return;

    const baseName = stripHalfPortionSuffix(item.name);
    const existing = groups.get(baseName) || { full: null, half: null };

    if (item.name.endsWith(HALF_PORTION_SUFFIX)) {
      existing.half = item;
    } else {
      existing.full = item;
    }

    groups.set(baseName, existing);
  });

  const displayItems = [];

  items.forEach((item) => {
    if (item.unit_type !== "item") {
      displayItems.push({ type: "single", item });
      return;
    }

    const baseName = stripHalfPortionSuffix(item.name);
    const group = groups.get(baseName);
    const hasBothVariants = Boolean(group?.full && group?.half);

    if (hasBothVariants) {
      if (item.name !== group.full.name) return;

      displayItems.push({
        type: "portion",
        baseName,
        variants: [
          { label: "Full", item: group.full },
          { label: "Half", item: group.half }
        ]
      });
      return;
    }

    if (item.name.endsWith(HALF_PORTION_SUFFIX) && group?.full) return;

    displayItems.push({ type: "single", item });
  });

  return displayItems;
};

const setMenuCardImageFallback = (card) => {
  const img = card.querySelector("img");
  if (!img) return;
  img.onerror = () => {
    img.src = FALLBACK_IMAGE;
  };
};

const createSingleMenuCard = (item) => {
  const card = document.createElement("article");
  card.className = "menu-card";
  const unitLabel = getUnitLabel(item.unit_type);
  const btnLabel =
    item.unit_type === "kg"
      ? "Select Weight"
      : item.unit_type === "piece"
        ? "Select Pieces"
        : "Add to cart";

  card.innerHTML = `
    <img src="${item.image_url || FALLBACK_IMAGE}" alt="${item.name}" />
    <div class="content">
      <h3>${item.name}</h3>
      <p>${item.description}</p>
      <div class="price">${currency.format(Number(item.price))} <span class="unit-label">${unitLabel}</span></div>
      <button class="btn ghost" type="button" data-add-item>${btnLabel}</button>
    </div>
  `;

  setMenuCardImageFallback(card);

  card.querySelector("[data-add-item]").addEventListener("click", () => {
    if (item.unit_type === "kg" || item.unit_type === "piece") {
      openQtyModal(item);
    } else {
      addToCart(item.id, 1);
    }
  });

  return card;
};

const createPortionMenuCard = ({ baseName, variants }) => {
  const card = document.createElement("article");
  card.className = "menu-card menu-card-portion";
  let selectedVariant = variants[0];

  const renderCard = () => {
    const selectedItem = selectedVariant.item;

    card.innerHTML = `
      <img src="${selectedItem.image_url || FALLBACK_IMAGE}" alt="${selectedItem.name}" />
      <div class="content">
        <div class="menu-card-header">
          <div>
            <h3>${baseName}</h3>
            <p class="menu-card-variant">${selectedVariant.label} Portion</p>
          </div>
          <div class="price">${currency.format(Number(selectedItem.price))}</div>
        </div>
        <p>${selectedItem.description}</p>
        <div class="portion-switcher" role="tablist" aria-label="${baseName} portion size">
          ${variants
            .map(
              (variant) => `
                <button
                  class="portion-option${variant.item.id === selectedItem.id ? " selected" : ""}"
                  type="button"
                  data-portion-id="${variant.item.id}"
                >
                  ${variant.label}
                </button>
              `
            )
            .join("")}
        </div>
        <button class="btn ghost" type="button" data-add-portion>Add to cart</button>
      </div>
    `;

    setMenuCardImageFallback(card);

    card.querySelectorAll("[data-portion-id]").forEach((button) => {
      button.addEventListener("click", () => {
        const nextVariant = variants.find(
          (variant) => String(variant.item.id) === button.dataset.portionId
        );
        if (!nextVariant) return;
        selectedVariant = nextVariant;
        renderCard();
      });
    });

    card.querySelector("[data-add-portion]").addEventListener("click", () => {
      addToCart(selectedItem.id, 1);
    });
  };

  renderCard();
  return card;
};

const renderMenu = (items) => {
  const grid = qs("#menu-grid");
  if (!grid) return;

  grid.innerHTML = "";
  if (!items.length) {
    grid.innerHTML = "<p>No items found for this category.</p>";
    return;
  }

  getMenuDisplayItems(items).forEach((entry) => {
    const card =
      entry.type === "portion"
        ? createPortionMenuCard(entry)
        : createSingleMenuCard(entry.item);

    grid.appendChild(card);
  });
};

const refreshCart = async () => {
  try {
    const result = await request(`/cart/${sessionId}`);
    state.cart = result.data;
    renderCart();
    renderCartSummary();
    renderCheckoutSummary();
    updateCartCount();
  } catch (error) {
    toast("Unable to refresh cart");
  }
};

const updateCartCount = () => {
  const count = state.cart.items.length;
  const badge = qs("#cart-count");
  if (badge) badge.textContent = count;
};

const addToCart = async (productId, quantity) => {
  if (window.shopIsOpen === false) {
    toast("Shop is currently closed.");
    return;
  }
  try {
    await request(`/cart/${sessionId}/items`, {
      method: "POST",
      body: JSON.stringify({ productId, quantity })
    });
    toast("Added to cart");
    refreshCart();
  } catch (error) {
    toast(error.message);
  }
};

const openQtyModal = (item) => {
  const overlay = qs("#qty-modal-overlay");
  const titleEl = qs("#qty-modal-title");
  const priceEl = qs("#qty-modal-price");
  const optionsEl = qs("#qty-modal-options");
  const totalEl = qs("#qty-modal-total");
  const addBtn = qs("#qty-modal-add");
  const closeBtn = qs("#qty-modal-close");

  if (!overlay) return;

  titleEl.textContent = item.name;
  const unitLabel = item.unit_type === "kg" ? "/kg" : "/piece";
  priceEl.textContent = `${currency.format(Number(item.price))} ${unitLabel}`;

  const options = item.unit_type === "kg" ? CAKE_WEIGHT_OPTIONS : PASTRY_PIECE_OPTIONS;
  let selectedQty = options[0];

  const renderOptions = () => {
    optionsEl.innerHTML = "";
    options.forEach((opt) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = `qty-option${opt === selectedQty ? " selected" : ""}`;
      btn.textContent = item.unit_type === "kg" ? `${opt} kg` : `${opt} pc${opt > 1 ? "s" : ""}`;
      btn.addEventListener("click", () => {
        selectedQty = opt;
        renderOptions();
        updateTotal();
      });
      optionsEl.appendChild(btn);
    });
  };

  const updateTotal = () => {
    const total = Number(item.price) * selectedQty;
    const qtyLabel = item.unit_type === "kg" ? `${selectedQty} kg` : `${selectedQty} pc${selectedQty > 1 ? "s" : ""}`;
    totalEl.textContent = `${qtyLabel} = ${currency.format(total)}`;
  };

  renderOptions();
  updateTotal();
  overlay.classList.add("open");

  const cleanup = () => {
    overlay.classList.remove("open");
    addBtn.replaceWith(addBtn.cloneNode(true));
    closeBtn.replaceWith(closeBtn.cloneNode(true));
  };

  qs("#qty-modal-add").addEventListener("click", () => {
    cleanup();
    addToCart(item.id, selectedQty);
  });

  qs("#qty-modal-close").addEventListener("click", cleanup);

  overlay.addEventListener("click", (e) => {
    if (e.target === overlay) cleanup();
  }, { once: true });
};

const updateCartItem = async (itemId, quantity) => {
  try {
    await request(`/cart/${sessionId}/items/${itemId}`, {
      method: "PATCH",
      body: JSON.stringify({ quantity })
    });
    refreshCart();
  } catch (error) {
    toast(error.message);
  }
};

const removeCartItem = async (itemId) => {
  try {
    await request(`/cart/${sessionId}/items/${itemId}`, {
      method: "DELETE"
    });
    refreshCart();
  } catch (error) {
    toast(error.message);
  }
};

const renderCart = () => {
  const container = qs("#cart-items");
  if (!container) return;

  container.innerHTML = "";

  if (!state.cart.items.length) {
    container.innerHTML = `
      <div class="summary-card">
        <h3>Your cart is empty</h3>
        <p>Add your favorite cakes, snacks, or drinks.</p>
        <a href="#menu" class="btn primary" data-link>Browse menu</a>
      </div>
    `;
    return;
  }

  state.cart.items.forEach((item) => {
    const card = document.createElement("div");
    card.className = "cart-item";
    const unitType = item.unitType || "item";
    const step = unitType === "kg" ? 0.5 : 1;
    const maxQty = unitType === "kg" ? 5 : 20;
    const qtyLabel = unitType === "kg" ? `${item.quantity} kg` : unitType === "piece" ? `${item.quantity} pc${item.quantity > 1 ? "s" : ""}` : `${item.quantity}`;
    const priceLabel = unitType === "kg" ? `${currency.format(item.unitPrice)}/kg` : unitType === "piece" ? `${currency.format(item.unitPrice)}/pc` : currency.format(item.unitPrice);
    card.innerHTML = `
      <header>
        <div>
          <strong>${item.name}</strong>
          <div class="price">${priceLabel}</div>
        </div>
        <button class="btn ghost" data-remove="${item.id}">Remove</button>
      </header>
      <p>${item.description}</p>
      <div class="quantity-controls">
        <button data-action="decrease" data-id="${item.id}">-</button>
        <strong>${qtyLabel}</strong>
        <button data-action="increase" data-id="${item.id}">+</button>
      </div>
      <div class="price" style="text-align:right">Total: ${currency.format(item.lineTotal)}</div>
    `;

    card.querySelector("[data-remove]").addEventListener("click", () => {
      removeCartItem(item.id);
    });

    card.querySelectorAll("[data-action]").forEach((btn) => {
      btn.addEventListener("click", () => {
        const action = btn.dataset.action;
        if (action === "increase" && item.quantity >= maxQty) {
          toast(unitType === "kg" ? "Maximum 5 kg" : "Maximum 20 per item");
          return;
        }
        const newQty = action === "increase" ? item.quantity + step : item.quantity - step;
        if (newQty <= 0) {
          removeCartItem(item.id);
        } else {
          updateCartItem(item.id, Number(newQty.toFixed(2)));
        }
      });
    });

    container.appendChild(card);
  });
};

const renderCartSummary = () => {
  const summary = qs("#cart-summary");
  if (!summary) return;

  if (!state.cart.items.length) {
    summary.innerHTML = "";
    return;
  }

  summary.innerHTML = `
    <h3>Order summary</h3>
    <div class="summary-row"><span>Subtotal</span><span>${currency.format(state.cart.totals.subtotal)}</span></div>
    <div class="summary-row"><span>Tax</span><span>${currency.format(state.cart.totals.tax)}</span></div>
    <div class="summary-row total"><span>Total</span><span>${currency.format(state.cart.totals.total)}</span></div>
    <a href="#checkout" class="btn primary" data-link>Checkout</a>
  `;
};

const renderCheckoutSummary = () => {
  const summary = qs("#checkout-summary");
  if (!summary) return;

  if (!state.cart.items.length) {
    summary.innerHTML = `
      <h3>Order summary</h3>
      <p>Your cart is empty.</p>
      <a href="#menu" class="btn primary" data-link>Browse menu</a>
    `;
    return;
  }

  const itemsList = state.cart.items
    .map(
      (item) => `
        <div class="summary-row">
          <span>${item.name} × ${item.quantity}</span>
          <span>${currency.format(item.lineTotal)}</span>
        </div>
      `
    )
    .join("");

  summary.innerHTML = `
    <h3>Order summary</h3>
    ${itemsList}
    <div class="summary-row"><span>Subtotal</span><span>${currency.format(state.cart.totals.subtotal)}</span></div>
    <div class="summary-row"><span>Tax</span><span>${currency.format(state.cart.totals.tax)}</span></div>
    <div class="summary-row total"><span>Total</span><span>${currency.format(state.cart.totals.total)}</span></div>
  `;
};

const handleCheckout = () => {
  const form = qs("#checkout-form");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (window.shopIsOpen === false) {
      toast("Shop is currently closed.");
      return;
    }
    const message = qs("#checkout-message");

    if (!state.cart.items.length) {
      if (message) message.textContent = "Your cart is empty.";
      return;
    }

    const data = Object.fromEntries(new FormData(form));
    const whatsappOptIn = data.whatsappOptIn === "on";

    try {
      const result = await request("/orders", {
        method: "POST",
        body: JSON.stringify({
          sessionId,
          customerName: data.customerName,
          phone: data.phone,
          notes: data.notes || "",
          whatsappOptIn
        })
      });

      form.reset();
      if (message) {
        message.textContent = `Order placed! Your order ID is ${result.data.orderId}.`;
      }
      showWhatsAppOrderLink(result.data.orderId);
      toast("Order placed successfully");
      refreshCart();
    } catch (error) {
      if (message) message.textContent = error.message;
      toast(error.message);
    }
  });
};

const escapeHtml = (value) =>
  String(value || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");

const humanizeStatus = (status) =>
  String(status || "")
    .replaceAll("_", " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());

const setAdminToken = (token) => {
  state.admin.token = token || "";
  if (state.admin.token) {
    localStorage.setItem(ADMIN_TOKEN_KEY, state.admin.token);
  } else {
    localStorage.removeItem(ADMIN_TOKEN_KEY);
  }
};

const adminHeaders = () => {
  if (!state.admin.token) return {};
  return {
    Authorization: `Bearer ${state.admin.token}`
  };
};

const setAdminLoginMessage = (message, isError = false) => {
  const el = qs("#admin-login-message");
  if (!el) return;
  el.textContent = message || "";
  el.style.color = isError ? "#8d2525" : "var(--accent-strong)";
};

const setAdminDashboardMessage = (message, isError = false) => {
  const el = qs("#admin-dashboard-message");
  if (!el) return;
  el.textContent = message || "";
  el.style.color = isError ? "#8d2525" : "var(--accent-strong)";
};

const renderAdminAuthState = (isLoggedIn) => {
  const loginCard = qs("#admin-login-card");
  const dashboard = qs("#admin-dashboard");
  const actions = qs("#admin-actions");

  if (loginCard) loginCard.hidden = isLoggedIn;
  if (dashboard) dashboard.hidden = !isLoggedIn;
  if (actions) actions.hidden = !isLoggedIn;
};

const clearAdminDashboard = () => {
  const metrics = qs("#admin-metrics");
  const currentOrders = qs("#admin-current-orders");
  const inTransitOrders = qs("#admin-in-transit-orders");

  if (metrics) metrics.innerHTML = "";
  if (currentOrders) currentOrders.innerHTML = "";
  if (inTransitOrders) inTransitOrders.innerHTML = "";
  setAdminDashboardMessage("");
};

const renderAdminMetrics = (summary) => {
  const metrics = qs("#admin-metrics");
  if (!metrics) return;

  metrics.innerHTML = `
    <article class="metric-card">
      <div class="metric-label">Current Orders</div>
      <div class="metric-value">${summary.currentOrdersCount}</div>
    </article>
    <article class="metric-card">
      <div class="metric-label">Orders In Transit</div>
      <div class="metric-value">${summary.inTransitOrdersCount}</div>
    </article>
    <article class="metric-card">
      <div class="metric-label">Day Earning</div>
      <div class="metric-value">${currency.format(summary.dayEarnings)}</div>
    </article>
    <article class="metric-card">
      <div class="metric-label">Month Earning</div>
      <div class="metric-value">${currency.format(summary.monthEarnings)}</div>
    </article>
    <article class="metric-card">
      <div class="metric-label">Year Earning</div>
      <div class="metric-value">${currency.format(summary.yearEarnings)}</div>
    </article>
  `;
};

const renderAdminOrders = (orders, selector, enableActions = false) => {
  const container = qs(selector);
  if (!container) return;

  if (!orders.length) {
    container.innerHTML = "<p class='admin-order-meta'>No orders found.</p>";
    return;
  }

  container.innerHTML = orders
    .map((order) => {
      const itemsHtml = order.items.length
        ? `<ul class="admin-order-items">${order.items
            .map(
              (item) =>
                `<li>${escapeHtml(item.name)} x ${item.quantity} (${currency.format(item.lineTotal)})</li>`
            )
            .join("")}</ul>`
        : "<p class='admin-order-meta'>No items available.</p>";

      const statusOptions = ADMIN_ORDER_STATUSES.map(
        (status) =>
          `<option value="${status}" ${
            status === order.status ? "selected" : ""
          }>${humanizeStatus(status)}</option>`
      ).join("");

      const actionHtml = enableActions
        ? `
          <div class="admin-order-actions">
            <select data-admin-status>
              ${statusOptions}
            </select>
            <button
              class="btn ghost"
              type="button"
              data-admin-update="${order.orderId}"
            >
              Update Status
            </button>
          </div>
        `
        : "";

      return `
        <article class="admin-order-card" data-order-id="${order.orderId}">
          <div class="admin-order-header">
            <span class="admin-order-id">Order #${order.orderId}</span>
            <span class="status-badge ${order.status}">
              ${humanizeStatus(order.status)}
            </span>
          </div>
          <p class="admin-order-meta">
            ${escapeHtml(order.customerName)} • ${escapeHtml(order.phone)}
          </p>
          <p class="admin-order-meta">
            Pickup order
          </p>
          <p class="admin-order-meta">
            Placed: ${new Date(order.createdAt).toLocaleString()}
          </p>
          <p class="admin-order-meta">
            Total: ${currency.format(order.totals.total)}
          </p>
          ${itemsHtml}
          ${actionHtml}
        </article>
      `;
    })
    .join("");
};

const renderDashboard = (dashboard) => {
  renderAdminMetrics(dashboard.summary);
  renderAdminOrders(dashboard.currentOrders || [], "#admin-current-orders", true);
  renderAdminOrders(
    dashboard.inTransitOrders || [],
    "#admin-in-transit-orders",
    false
  );
};

const loadAdminDashboard = async () => {
  const hasToken = Boolean(state.admin.token);
  renderAdminAuthState(hasToken);

  if (!hasToken) {
    clearAdminDashboard();
    return;
  }

  setAdminDashboardMessage("Loading admin dashboard...");

  try {
    const result = await request("/admin/dashboard", {
      headers: adminHeaders()
    });
    renderDashboard(result.data);
    setAdminDashboardMessage("");
  } catch (error) {
    if (/token|auth|expired/i.test(error.message)) {
      setAdminToken("");
      renderAdminAuthState(false);
      clearAdminDashboard();
      setAdminLoginMessage("Session expired. Please login again.", true);
      return;
    }
    setAdminDashboardMessage(error.message, true);
  }
};

const handleAdminLogin = () => {
  const form = qs("#admin-login-form");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = form.querySelector("button[type='submit']");
    if (submitButton) submitButton.disabled = true;

    const data = Object.fromEntries(new FormData(form));
    setAdminLoginMessage("Signing in...");

    try {
      const result = await request("/admin/login", {
        method: "POST",
        body: JSON.stringify({
          username: data.username,
          password: data.password
        })
      });
      setAdminToken(result.data.token);
      form.reset();
      setAdminLoginMessage("");
      renderAdminAuthState(true);
      await loadAdminDashboard();
      toast("Admin login successful");
    } catch (error) {
      setAdminLoginMessage(error.message, true);
    } finally {
      if (submitButton) submitButton.disabled = false;
    }
  });
};

const handleAdminControls = () => {
  const logoutButton = qs("#admin-logout");
  const refreshButton = qs("#admin-refresh");
  const currentOrders = qs("#admin-current-orders");

  if (logoutButton) {
    logoutButton.addEventListener("click", () => {
      setAdminToken("");
      renderAdminAuthState(false);
      clearAdminDashboard();
      setAdminLoginMessage("Logged out.");
      toast("Admin logged out");
    });
  }

  if (refreshButton) {
    refreshButton.addEventListener("click", () => {
      loadAdminDashboard();
    });
  }

  if (currentOrders) {
    currentOrders.addEventListener("click", async (event) => {
      const button = event.target.closest("[data-admin-update]");
      if (!button) return;

      const orderId = button.getAttribute("data-admin-update");
      const card = button.closest("[data-order-id]");
      const statusSelect = card?.querySelector("[data-admin-status]");
      const status = statusSelect?.value;
      if (!status || !orderId) return;

      button.disabled = true;
      setAdminDashboardMessage(`Updating order #${orderId}...`);

      try {
        await request(`/orders/${orderId}/status`, {
          method: "PATCH",
          headers: adminHeaders(),
          body: JSON.stringify({ status })
        });
        setAdminDashboardMessage(
          `Order #${orderId} updated to ${humanizeStatus(status)}.`
        );
        await loadAdminDashboard();
      } catch (error) {
        setAdminDashboardMessage(error.message, true);
      } finally {
        button.disabled = false;
      }
    });
  }
};

const hydrateWhatsAppLinks = () => {
  const links = qsa("[data-whatsapp]");
  const hasNumber = Boolean(sanitizeWhatsAppNumber(WHATSAPP_NUMBER));
  const notes = qsa("[data-whatsapp-note]");

  if (!hasNumber) {
    links.forEach((link) => {
      link.style.display = "none";
    });
    notes.forEach((note) => {
      note.style.display = "none";
    });
    return;
  }

  links.forEach((link) => {
    const message = link.dataset.message || "Hi! I would like to place an order.";
    const href = buildWhatsAppLink(message);
    if (!href) {
      link.style.display = "none";
      return;
    }
    link.setAttribute("href", href);
  });
};

const showWhatsAppOrderLink = (orderId) => {
  const container = qs("#whatsapp-cta");
  if (!container) return;
  const href = buildWhatsAppLink(
    `Hi! I just placed order #${orderId}. Please share live updates.`
  );
  if (!href) {
    container.innerHTML = "";
    return;
  }
  container.innerHTML = `
    <a class="btn ghost" href="${href}" target="_blank" rel="noopener">
      Track on WhatsApp
    </a>
  `;
};

const initNav = () => {
  const toggle = qs(".nav-toggle");
  const nav = qs(".nav-links");

  if (toggle && nav) {
    toggle.addEventListener("click", () => {
      nav.classList.toggle("open");
    });
  }

  qsa("[data-link]").forEach((link) => {
    link.addEventListener("click", () => {
      if (nav) nav.classList.remove("open");
    });
  });
};

const checkShopStatus = () => {
  const now = new Date();
  const hours = now.getHours();
  const minutes = now.getMinutes();
  const time = hours + minutes / 60;

  // 12:00 to 16:00 AND 17:30 to 22:00
  const isOpen = (time >= 12 && time < 16) || (time >= 17.5 && time < 22);
  
  window.shopIsOpen = isOpen;

  let banner = qs("#shop-status-banner");
  if (!banner) {
    banner = document.createElement("div");
    banner.id = "shop-status-banner";
    const main = qs(".site-main");
    if (main) {
      main.prepend(banner);
    }
  }

  if (isOpen) {
    document.body.classList.remove("shop-closed");
    banner.classList.remove("closed");
    banner.innerHTML = "";
  } else {
    document.body.classList.add("shop-closed");
    if (!banner.classList.contains("closed")) {
      banner.classList.add("closed");
      banner.innerHTML = `
        <div class="banner-content">
          <span class="icon">🌙</span>
          <p><strong>We are currently closed.</strong> Our shop hours are 12:00 PM - 4:00 PM and 5:30 PM - 10:00 PM.</p>
        </div>
      `;
    }
  }
};

const init = () => {
  initNav();
  handleAdminLogin();
  handleAdminControls();
  handleRouting();
  window.addEventListener("hashchange", handleRouting);

  hydrateWhatsAppLinks();
  loadCategories();
  loadMenu("All");
  refreshCart();
  handleCheckout();

  checkShopStatus();
  setInterval(checkShopStatus, 60000); // Re-check every minute
};

init();
