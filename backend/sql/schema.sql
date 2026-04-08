-- Cakes n Bakes 365 schema and seed data

CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  unit_type TEXT NOT NULL DEFAULT 'item',
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS carts (
  id SERIAL PRIMARY KEY,
  session_id TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cart_items (
  id SERIAL PRIMARY KEY,
  cart_id INTEGER NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  session_id TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  notes TEXT,
  whatsapp_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  subtotal NUMERIC(10, 2) NOT NULL,
  tax NUMERIC(10, 2) NOT NULL,
  total NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  quantity NUMERIC(10, 2) NOT NULL,
  unit_price NUMERIC(10, 2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_unique ON products(category_id, name);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_orders_session ON orders(session_id);

-- Categories
INSERT INTO categories (name)
VALUES ('Cakes'), ('Pastries'), ('Fast Food'), ('Snacks'), ('Drinks')
ON CONFLICT DO NOTHING;

-- ============================================================
-- CAKES (unit_type = 'kg', price is per kg)
-- ============================================================

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'PineApple Cake', 'Fresh pineapple cake with cream layers.', 500, 'kg',
  '/assets/PineApple-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'BlackForest Cake', 'Chocolate cake with cherries and whipped cream.', 600, 'kg',
  '/assets/BlackForest-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'ChocoChip Cake', 'Rich chocolate cake loaded with choco chips.', 700, 'kg',
  '/assets/ChocoChip-cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'ButterScotch Cake', 'Butterscotch flavored cake with caramel drizzle.', 520, 'kg',
  '/assets/ButterScotch-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'BlueBerry Cake', 'Soft blueberry cake with fresh cream.', 600, 'kg',
  '/assets/BlueBerry-Cake.jpeg'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'RedVelvet Cake', 'Classic red velvet with cream cheese frosting.', 700, 'kg',
  '/assets/RedValvet-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Truffle Cake', 'Rich chocolate truffle cake with ganache.', 800, 'kg',
  '/assets/Truffle-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Fruit Cake', 'Fresh fruit cake with seasonal fruits and cream.', 800, 'kg',
  '/assets/Fruit-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'RasMalai Cake', 'Indian fusion rasmalai flavored cake.', 700, 'kg',
  '/assets/RasMali-cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Mango Cake', 'Seasonal mango cake with mango cream layers.', 750, 'kg',
  '/assets/Mango-Cake.png'
FROM categories WHERE name = 'Cakes'
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASTRIES (unit_type = 'piece', price is per piece)
-- ============================================================

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'PineApple Pastry', 'Soft pineapple pastry with cream topping.', 35, 'piece',
  '/assets/PineApple-Pastery.png'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'BlackForest Pastry', 'Chocolate pastry with cherry and cream.', 40, 'piece',
  '/assets/BlackForest-pastry.png'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'ChocoChip Pastry', 'Pastry topped with choco chips and cream.', 45, 'piece',
  '/assets/ChocoChip-Pastry.png'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'ButterScotch Pastry', 'Butterscotch flavored pastry with caramel.', 35, 'piece',
  '/assets/ButterScotch-Pastry.png'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'BlueBerry Pastry', 'Fresh blueberry pastry with cream.', 40, 'piece',
  '/assets/BlueBerry-Cake.jpeg'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'RedVelvet Pastry', 'Red velvet pastry with cream cheese.', 45, 'piece',
  '/assets/RedValvet-Pastry.png'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Truffle Pastry', 'Chocolate truffle pastry with ganache.', 60, 'piece',
  '/assets/Truffle-Pastry.png'
FROM categories WHERE name = 'Pastries'
ON CONFLICT DO NOTHING;

-- INSERT INTO products (category_id, name, description, price, unit_type, image_url)
-- SELECT id, 'Fruit Pastry', 'Fresh fruit pastry with seasonal fruits.', 60, 'piece',
--   'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=900&q=80'
-- FROM categories WHERE name = 'Pastries'
-- ON CONFLICT DO NOTHING;

-- INSERT INTO products (category_id, name, description, price, unit_type, image_url)
-- SELECT id, 'RasMalai Pastry', 'Rasmalai flavored pastry with cream.', 45, 'piece',
--   'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=900&q=80'
-- FROM categories WHERE name = 'Pastries'
-- ON CONFLICT DO NOTHING;

-- INSERT INTO products (category_id, name, description, price, unit_type, image_url)
-- SELECT id, 'Mango Pastry', 'Seasonal mango pastry with cream.', 50, 'piece',
--   'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=900&q=80'
-- FROM categories WHERE name = 'Pastries'
-- ON CONFLICT DO NOTHING;

-- ============================================================
-- FAST FOOD (unit_type = 'item', same as before)
-- ============================================================

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Classic Veg Burger', 'Loaded veg patty with fresh lettuce and cheese.', 50, 'item',
  '/assets/Burger.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Cheese Burger', 'Extra cheesy burger with a toasted bun.', 70, 'item',
  '/assets/Cheese-Burge.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Sandwich', 'Freshly layered sandwich with tangy spread.', 30, 'item',
  '/assets/Cold-Sandwich.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Grilled Sandwich', 'Golden grilled sandwich with melted cheese.', 90, 'item',
  '/assets/Grilled-Sandwich.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Cheese Pasta', 'Creamy red/white sauce pasta with veggies.', 120, 'item',
  '/assets/Pasta.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'French Fries', 'Crispy golden fries with seasoning.', 70, 'item',
  '/assets/FrenchFries.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Chilly Paneer Gravy', 'Paneer tossed in spicy, tangy gravy.', 240, 'item',
  '/assets/ChillyPaneer-Gravy.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Manchurian Dry', 'Crispy veg balls in a spicy glaze.', 200, 'item',
  '/assets/mancurian-dry.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Hakka Noodles', 'Wok-tossed noodles with fresh veggies.', 140, 'item',
  '/assets/hakka-noddles.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Fried Rice', 'Aromatic fried rice with herbs.', 120, 'item',
  '/assets/fried-rice.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Chilly Paneer Dry', 'Spicy paneer tossed with peppers and onions.', 220, 'item',
  '/assets/ChillyPaneer-Dry.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Manchurian Gravy', 'Veg balls in a tangy gravy.', 220, 'item',
  '/assets/manchurian-gravy.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Manchurian Gravy (Half)', 'Half portion of veg manchurian gravy.', 120, 'item',
  '/assets/manchurian-gravy.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Manchurian Dry (Half)', 'Half portion of veg manchurian dry.', 120, 'item',
  '/assets/mancurian-dry.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Crispy Honey Chilly Potato', 'Crispy potato tossed in honey chilli sauce.', 150, 'item',
  '/assets/Chilly-potato.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Spring Roll', 'Golden spring rolls with veggie filling.', 100, 'item',
  '/assets/Spring-roll.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Chowmein', 'Stir-fried chowmein with veggies.', 100, 'item',
  '/assets/chowmein.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Chowmein (Half)', 'Half portion of veg chowmein.', 60, 'item',
  '/assets/chowmein.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Hakka Noodles (Half)', 'Half portion of veg hakka noodles.', 80, 'item',
  '/assets/hakka-noddles.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Garlic Noodles', 'Garlic-infused noodles with veggies.', 130, 'item',
  '/assets/garlic-noodles.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Garlic Noodles (Half)', 'Half portion of veg garlic noodles.', 80, 'item',
  '/assets/garlic-noodles.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Exotic Hakka Noodles', 'Spicy hakka noodles with exotic veggies.', 150, 'item',
  '/assets/ExoticHakka-Noddles.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Exotic Hakka Noodles (Half)', 'Half portion of exotic hakka noodles.', 90, 'item',
  '/assets/ExoticHakka-Noddles.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Fried Rice (Half)', 'Half portion of veg fried rice.', 70, 'item',
  '/assets/fried-rice.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Garlic Fried Rice', 'Garlic fried rice with herbs.', 140, 'item',
  '/assets/GarlicFried-Rice.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Garlic Fried Rice (Half)', 'Half portion of garlic fried rice.', 80, 'item',
  '/assets/GarlicFried-Rice.png'
FROM categories WHERE name = 'Fast Food'
ON CONFLICT DO NOTHING;

-- ============================================================
-- SNACKS (unit_type = 'item')
-- ============================================================

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Cheese Corn Nuggets (8 pcs)', 'Crunchy nuggets with sweet corn and cheese.', 80, 'item',
  '/assets/cheese-corn-nugget.png'
FROM categories WHERE name = 'Snacks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Hara Bhara Kebab (8 pcs)', 'Herby, shallow-fried veg kebabs.', 80, 'item',
  '/assets/hara-bhara-kebab.png'
FROM categories WHERE name = 'Snacks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Seekh Kebab (3 pcs)', 'Smoky seekh kebabs with mild spices.', 100, 'item',
  '/assets/seekh-kebab.png'
FROM categories WHERE name = 'Snacks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Kurkure Momos (6 pcs)', 'Crispy momos with spicy chutney.', 100, 'item',
  '/assets/kurkure-momos.png'
FROM categories WHERE name = 'Snacks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Hot & Sour Soup', 'Classic hot and sour soup.', 50, 'item',
  '/assets/hot-n-sour.png'
FROM categories WHERE name = 'Snacks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Veg Sweet Corn Soup', 'Comforting sweet corn soup.', 50, 'item',
  '/assets/corn-soup.png'
FROM categories WHERE name = 'Snacks'
ON CONFLICT DO NOTHING;

-- ============================================================
-- DRINKS (unit_type = 'item')
-- ============================================================

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Cold Coffee', 'Chilled coffee blended with milk.', 70, 'item',
  '/assets/cold-coffee.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Cold Coffee with Ice Cream', 'Thick cold coffee topped with ice cream.', 90, 'item',
  '/assets/coldcoffee-wi.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Strawberry Shake', 'Creamy strawberry shake made fresh.', 70, 'item',
  '/assets/strawberryshake.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Mango Shake', 'Seasonal mango shake with rich cream.', 80, 'item',
  '/assets/mango-shake.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Oreo Shake', 'Chocolatey Oreo shake with cookie crumble.', 80, 'item',
  '/assets/oreoshake.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Hot Coffee', 'Freshly brewed hot coffee.', 40, 'item',
  '/assets/coffee.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Hot Chocolate', 'Velvety hot chocolate.', 80, 'item',
  '/assets/hotchocolate.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Tea', 'Classic hot tea.', 20, 'item',
  '/assets/tea.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Mojito', 'Refreshing mint-lime cooler.', 60, 'item',
  '/assets/mojito.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Fresh Lime Soda', 'Sparkling lime soda with a zing.', 50, 'item',
  '/assets/freshlime-soda.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, name, description, price, unit_type, image_url)
SELECT id, 'Shikanji', 'Traditional lemon drink with spices.', 50, 'item',
  '/assets/shikanji.png'
FROM categories WHERE name = 'Drinks'
ON CONFLICT DO NOTHING;
