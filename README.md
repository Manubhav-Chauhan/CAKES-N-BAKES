# CAKES-N-BAKES
Cakes n Bakes 365 A Production-Grade Full-Stack Bakery Ordering Platform with End-to-End DevOps Pipeline
The project serves a dual purpose:

Functional Application — A complete e-commerce storefront with menu browsing, cart management, order placement, admin dashboard, and WhatsApp order notifications via Twilio.
DevOps Showcase — A comprehensive demonstration of containerization, CI/CD, orchestration, IaC, configuration management, monitoring, service mesh, and chaos engineering.

Key Features
Feature	Description
Online Ordering	Browse menu by category, add to cart with quantity selection (kg/piece/item), and checkout
WhatsApp Notifications	Order confirmations sent to customers & admin via Twilio WhatsApp API
Admin Dashboard	Protected admin panel for managing orders (accept/reject/complete)
Shop Hours Banner	Time-aware UI that shows shop status and disables ordering when closed
SSL/TLS	Self-signed certificate with automatic generation via Nginx reverse proxy
Prometheus Metrics	Built-in /metrics endpoint exposing request latency, throughput, and error rates
HPA Auto-scaling	Horizontal Pod Autoscaler for backend (2-5 pods) and frontend (2-4 pods)
