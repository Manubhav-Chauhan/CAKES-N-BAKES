# CAKES-N-BAKES
Cakes n Bakes 365 A Production-Grade Full-Stack Bakery Ordering Platform with End-to-End DevOps Pipeline
The project serves a dual purpose:

Functional Application — A complete e-commerce storefront with menu browsing, cart management, order placement, admin dashboard, and WhatsApp order notifications via Twilio.
DevOps Showcase — A comprehensive demonstration of containerization, CI/CD, orchestration, IaC, configuration management, monitoring, service mesh, and chaos engineering.
 ARCHITECTURE
 System Overview
 ┌─────────────────────────────────────────────────────────────┐
│                        CLIENTS                              │
│                   (Browser / Mobile)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS (443) / HTTP (80 → 301)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   NGINX REVERSE PROXY                       │
│          SSL Termination • Basic Auth (/admin)              │
│              HTTP→HTTPS Redirect • Routing                  │
└──────┬─────────────────────────────────┬────────────────────┘
       │ /api/*                          │ /*
       ▼                                 ▼
┌──────────────┐                ┌─────────────────┐
│   BACKEND    │                │    FRONTEND      │
│  Express.js  │                │  Nginx + Static  │
│  Port 4000   │                │  HTML/CSS/JS     │
│              │                │  Port 80         │
│  • REST API  │                │                  │
│  • /metrics  │                │  • SPA Router    │
│  • Zod valid.│                │  • Cart logic    │
│  • Helmet    │                │  • Admin panel   │
└──────┬───────┘                └──────────────────┘
       │
       ▼
┌──────────────┐       ┌───────────────────┐
│  PostgreSQL  │       │   Twilio WhatsApp  │
│  Port 5432   │       │   (External API)   │
│              │       └───────────────────┘
│  • Products  │
│  • Carts     │
│  • Orders    │
└──────────────┘
